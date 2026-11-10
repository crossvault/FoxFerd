# Gebuendelte Dateioperationen: keine PowerShell-Bindung pro Byte oder Dateikopie.
if (-not ('FoxFerd.TestIO' -as [type])) {
    Add-Type -ReferencedAssemblies System.Web.Extensions, System.Xml, System.Core -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;
using System.Web.Script.Serialization;
using System.Xml;
using System.Threading.Tasks;

namespace FoxFerd {
    public static class TestIO {
        public static string HashBytes(byte[] bytes) {
            using (var sha = SHA256.Create()) {
                return BitConverter.ToString(sha.ComputeHash(bytes)).Replace("-", "").ToLowerInvariant();
            }
        }

        public static string HashFile(string path) {
            using (var sha = SHA256.Create())
            using (var stream = File.OpenRead(path)) {
                return BitConverter.ToString(sha.ComputeHash(stream)).Replace("-", "").ToLowerInvariant();
            }
        }

        public static Dictionary<string, object> ReadJson(string path) {
            return ParseJson(File.ReadAllText(path));
        }

        public static Dictionary<string, object> ParseJson(string text) {
            var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
            return serializer.Deserialize<Dictionary<string, object>>(text);
        }

        public static void WriteJson(string path, object value) {
            var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
            File.WriteAllText(path, serializer.Serialize(value) + "\r\n", System.Text.Encoding.ASCII);
        }

        // Vollstaendiger Vergleich der frisch gelesenen Bytes, ohne Hashannahme.
        public static bool SameBytes(byte[] left, byte[] right) {
            if (left.Length != right.Length) return false;
            for (int i = 0; i < left.Length; i++) {
                if (left[i] != right[i]) return false;
            }
            return true;
        }

        public static int CompareXml(string left, string right) {
            var files = Directory.GetFiles(left, "*.xml", SearchOption.AllDirectories);
            var others = Directory.GetFiles(right, "*.xml", SearchOption.AllDirectories);
            if (files.Length != others.Length) throw new Exception("XML: unterschiedliche Dateimengen.");
            Array.Sort(files, StringComparer.Ordinal);
            var errors = new string[files.Length];
            Parallel.For(0, files.Length, IoOptions(), i => {
                var file = files[i];
                var relative = file.Substring(left.Length).TrimStart('\\', '/');
                var other = Path.Combine(right, relative);
                try {
                    if (!File.Exists(other)) errors[i] = "XML: fehlt in VFPA: " + relative;
                    else {
                        var a = File.ReadAllBytes(file);
                        var b = File.ReadAllBytes(other);
                        if (a.Length != b.Length) errors[i] = "XML: Laengendifferenz " + relative;
                        else if (!SameBytes(a, b)) errors[i] = "XML: Bytedifferenz " + relative;
                    }
                } catch (Exception error) { errors[i] = "XML: " + relative + ": " + error.Message; }
            });
            foreach (var error in errors) if (error != null) throw new Exception(error);
            return files.Length;
        }

        private static ParallelOptions IoOptions() {
            return new ParallelOptions { MaxDegreeOfParallelism = Math.Min(4, Math.Max(1, Environment.ProcessorCount - 2)) };
        }

        public static Dictionary<string, byte[]> ReadFiles(string[] paths) {
            var bytes = new byte[paths.Length][];
            var errors = new string[paths.Length];
            Parallel.For(0, paths.Length, IoOptions(), i => {
                try { bytes[i] = File.ReadAllBytes(paths[i]); }
                catch (Exception error) { errors[i] = "BERICHT: " + paths[i] + ": " + error.Message; }
            });
            var result = new Dictionary<string, byte[]>(StringComparer.Ordinal);
            for (int i = 0; i < paths.Length; i++) {
                if (errors[i] != null) throw new Exception(errors[i]);
                result.Add(paths[i], bytes[i]);
            }
            return result;
        }

        public static void MergeXml(string source, string destination) {
            var directories = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var file in Directory.EnumerateFiles(source, "*.xml", SearchOption.AllDirectories)) {
                var relative = file.Substring(source.Length).TrimStart('\\');
                var target = Path.Combine(destination, relative);
                if (File.Exists(target)) {
                    if (!SameBytes(File.ReadAllBytes(file), File.ReadAllBytes(target)))
                        throw new Exception("VFP-MERGE: widerspruechliche XML-Datei: " + relative);
                } else {
                    var directory = Path.GetDirectoryName(target);
                    if (directories.Add(directory)) Directory.CreateDirectory(directory);
                    File.Copy(file, target);
                }
            }
        }

        public static XmlDocument LoadXml(byte[] bytes) {
            var settings = new XmlReaderSettings { DtdProcessing = DtdProcessing.Prohibit, XmlResolver = null };
            using (var stream = new MemoryStream(bytes, false))
            using (var reader = XmlReader.Create(stream, settings)) {
                var document = new XmlDocument { XmlResolver = null };
                document.Load(reader);
                return document;
            }
        }
    }
}
'@
}
