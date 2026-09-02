using System;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text;

namespace Webcon.Addon.VatWhitelist.Plugin.Register
{
    /// <summary>
    /// The register's response, and the register's error.
    ///
    /// Serialised with DataContractJsonSerializer, which is in netstandard2.0 itself. That
    /// is the whole reason for choosing it: System.Text.Json and Newtonsoft.Json both work,
    /// and both would be libraries to ship, declare in the manifest's dependencies node, and
    /// place by runtime -- .NET Framework 4.7.2 for the Service, .NET 9 for the Portal --
    /// which docs/dependencies.md calls the most common integration failure. The SDK brings
    /// no JSON library of its own (checked: its only NuGet dependency is
    /// Microsoft.Data.SqlClient), so using one means owning that problem. For four fields
    /// out of a flat response, it is not worth owning.
    ///
    /// NFR-4 falls out of the same choice: DataContractJsonSerializer ignores JSON members
    /// it has no DataMember for. The register already sends two fields absent from its
    /// published list (exemptionSmeDate, hasVirtualAccounts) and will send more.
    /// </summary>
    [DataContract]
    public class VatSearchResponse
    {
        [DataMember(Name = "result")]
        public VatSearchResult Result { get; set; }
    }

    [DataContract]
    public class VatSearchResult
    {
        /// <summary>
        /// Null when the register holds no such NIP -- with HTTP 200, not 404. That shape
        /// is documented nowhere (finding 3) and is the reason FR-4 exists.
        /// </summary>
        [DataMember(Name = "subject")]
        public VatSubject Subject { get; set; }

        [DataMember(Name = "requestId")]
        public string RequestId { get; set; }

        /// <summary>
        /// dd-MM-yyyy HH:mm:ss in Europe/Warsaw local time. Deliberately a string: it is
        /// evidence (FR-6), and parsing it into a DateTime turns something the Ministry
        /// issued into something we reformatted.
        /// </summary>
        [DataMember(Name = "requestDateTime")]
        public string RequestDateTime { get; set; }
    }

    [DataContract]
    public class VatSubject
    {
        [DataMember(Name = "name")]
        public string Name { get; set; }

        [DataMember(Name = "nip")]
        public string Nip { get; set; }

        /// <summary>
        /// Polish, verbatim, as returned (NFR-3). Observed: "Czynny", "Zwolniony". A third
        /// value exists and is unverified (finding 7), so nothing may compare this against a
        /// hardcoded string for the negative case -- anything that is not "Czynny" is
        /// "not an active VAT payer", by exclusion.
        /// </summary>
        [DataMember(Name = "statusVat")]
        public string StatusVat { get; set; }

        [DataMember(Name = "regon")]
        public string Regon { get; set; }

        [DataMember(Name = "krs")]
        public string Krs { get; set; }
    }

    /// <summary>
    /// The error body. FLAT, at the top level, with HTTP 400.
    ///
    /// The published swagger example shows {"exception":{...}}. A model built from that
    /// example finds no such object here, deserialises to nulls, and reports a transport
    /// failure for what was a plain bad request with a code that says exactly what is wrong.
    /// Verified codes: WL-102 date format, WL-103 future date, WL-115 bad NIP,
    /// WL-118 date before the register's range.
    /// </summary>
    [DataContract]
    public class VatRegisterError
    {
        [DataMember(Name = "code")]
        public string Code { get; set; }

        [DataMember(Name = "message")]
        public string Message { get; set; }
    }

    public static class VatRegisterJson
    {
        public static T Parse<T>(string json) where T : class
        {
            if (string.IsNullOrWhiteSpace(json)) return null;

            using (var stream = new MemoryStream(Encoding.UTF8.GetBytes(json)))
            {
                var serializer = new DataContractJsonSerializer(typeof(T));
                return serializer.ReadObject(stream) as T;
            }
        }
    }
}
