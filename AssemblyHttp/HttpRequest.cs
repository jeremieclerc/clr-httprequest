using System;
using System.Data.SqlTypes;
using System.Collections;
using Microsoft.SqlServer.Server;
using System.IO;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.ComponentModel.Design;
using System.Collections.Generic;
using System.Diagnostics;

public partial class UserDefinedFunctions
{
    private class HttpReponseObject
    {
        public SqlInt32 rStatusCode;
        public SqlString rBody;
        public SqlString rHeaders;
        public HttpReponseObject(SqlInt32 StatusCode, SqlString Body, SqlString Headers)
        {
            rStatusCode = StatusCode;
            rBody = Body;
            rHeaders = Headers;
        }
    }

    [SqlFunction(FillRowMethodName = "FillRowHttpRequest", TableDefinition = "StatusCode INT, Response NVARCHAR(MAX), Headers NVARCHAR(MAX)", DataAccess = DataAccessKind.Read, IsDeterministic = false)]
    public static IEnumerable HttpRequest(SqlString requestType, SqlString url, SqlString headers, SqlString body)
    {
        string iMethod = requestType.ToString().ToUpper().Trim();
        string iUrl = url.ToString();
        string iHeaders = headers.ToString();
        string iBody = body.ToString();
        bool isContentTypeDefined = false;
        bool isContentLengthDefined = false;
        long temp;

        int rCode = 0;
        string rBody = "";
        string rHeaders = "";

        WebHeaderCollection rDictHeaders = new WebHeaderCollection();
        ArrayList responseCollection = new ArrayList();
        string[] items = new string[0];

        try
        {
            if (iMethod != "GET" && iMethod != "POST" && iMethod != "PUT" && iMethod != "HEAD" && iMethod != "DELETE" && iMethod != "TRACE" && iMethod != "OPTIONS")
            {
                rBody = "Method not supported. Methods used : " + iMethod + ". List of supported methods : GET, POST, PUT, HEAD, DELETE, TRACE, OPTIONS.";
            }
            else if (iUrl == "Null")
            {
                rBody = "Please specify an URL to request";
            }
            else if (iUrl.Length <= 3 || iUrl.Length > 2000)
            {
                rBody = "URL not supported. URL length must be between 3 and 2000. Current length : " + iUrl.Length + ". URL Value: " + iUrl;
            }
            else
            {
                ServicePointManager.SecurityProtocol = (SecurityProtocolType)192 | (SecurityProtocolType)768 | (SecurityProtocolType)3072;
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(iUrl);
                request.Method = iMethod;

                // Parse the headers
                var headersDict = ParseHeaders(iHeaders);

                foreach (var kvp in headersDict)
                {
                    Debug.WriteLine(kvp.Key + " - " + kvp.Value);
                    // Handle each header based on its key
                    switch (kvp.Key.ToUpper())
                    {
                        case "ACCEPT":
                            request.Accept = kvp.Value;
                            break;
                        case "CONNECTION":
                            if (kvp.Value.ToUpper() == "CLOSE")
                            {
                                request.KeepAlive = false;
                            }
                            break;
                        case "DATE":
                            request.Date = DateTime.Parse(kvp.Value);
                            break;
                        case "IF-MODIFIED-SINCE":
                            request.IfModifiedSince = DateTime.Parse(kvp.Value);
                            break;
                        case "EXPECT":
                            request.Expect = kvp.Value;
                            break;
                        case "HOST":
                            request.Host = kvp.Value;
                            break;
                        case "REFERER":
                            request.Referer = kvp.Value;
                            break;
                        case "TRANSFER-ENCODING":
                            request.TransferEncoding = kvp.Value;
                            break;
                        case "USER-AGENT":
                            request.UserAgent = kvp.Value;
                            break;
                        case "RANGE":
                            string[] rangeParts = kvp.Value.Split('-');
                            if (rangeParts.Length == 2)
                            {
                                request.AddRange(int.Parse(rangeParts[0]), int.Parse(rangeParts[1]));
                            }
                            break;
                        case "CONTENT-TYPE":
                            request.ContentType = kvp.Value;
                            break;
                        case "CONTENT-LENGTH":
                            if (long.TryParse(kvp.Value, out long contentLength))
                            {
                                request.ContentLength = contentLength;
                            }
                            break;
                        case "TIMEOUT":
                            if (int.TryParse(kvp.Value, out int timeout))
                            {
                                request.Timeout = timeout > 0 ? timeout : -1;
                            }
                            break;
                        case "VERIFY":
                            if (kvp.Value.ToUpper() == "FALSE")
                            {
                                request.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;
                            }
                            break;
                        default:
                            if (kvp.Key.Length > 2)
                            {
                                request.Headers.Add(kvp.Key, kvp.Value);
                            }
                            break;
                    }
                }


                if (iMethod != "GET" && iBody.Length > 0 && iBody != "Null") // POST, PUT etc
                {
                    byte[] byteArray = Encoding.UTF8.GetBytes(iBody);
                    if (isContentTypeDefined == false)
                    {
                        request.ContentType = "application/x-www-form-urlencoded";
                    }
                    if (isContentLengthDefined == false)
                    {
                        request.ContentLength = byteArray.Length;
                    }
                    var reqStream = request.GetRequestStream();
                    reqStream.Write(byteArray, 0, byteArray.Length);
                    reqStream.Close();
                }

                HttpWebResponse webResponse = (HttpWebResponse)request.GetResponse();
                StreamReader reader = new StreamReader(webResponse.GetResponseStream());
                rBody = reader.ReadToEnd();
                rCode = (int)webResponse.StatusCode;
                rDictHeaders = webResponse.Headers;
                webResponse.Close();
                reader.Close();
            }
        }
        catch (WebException ex)
        {
            if (ex.Response != null)
            {
                HttpWebResponse exResponse = ex.Response as HttpWebResponse;
                rCode = ((int)exResponse.StatusCode);
                rBody = new StreamReader(ex.Response.GetResponseStream()).ReadToEnd();
                rDictHeaders = exResponse.Headers;
                exResponse.Close();
            }
            else
            {
                rBody = ex.Message;
                rCode = ex.HResult;
            }
        }


        if (rDictHeaders.Count > 0)
        {
            rHeaders = "{";
            foreach (string rKey in rDictHeaders.AllKeys)
            {
                rHeaders += "\"" + rKey + "\":\"" + rDictHeaders[rKey].Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t") + "\",";
            }
            rHeaders = rHeaders.Remove(rHeaders.Length - 1, 1) + "}";
        }
        if (rBody == null || rBody.Length == 0)
        {
            rBody = null;
        }
        if (rCode == -2146233079 && rBody != null)
        {
            if (rBody.Contains("SSL"))
            {
                rBody += " You can bypass the SSL/TLS check using the  header: {\"Verify\":\"False\"}";
            }
            else if (rBody.Contains("timeout"))
            {
                rBody += " You can increase your timeout using the header: {\"Timeout\":-1}";
            }
        }
        if (rHeaders == null || rHeaders.Length == 0)
        {
            rHeaders = null;
        }

        responseCollection.Add(new HttpReponseObject(rCode, rBody, rHeaders));
        return responseCollection;
    }

    public static void FillRowHttpRequest(object obj, out SqlInt32 StatusCode, out SqlString Response, out SqlString Headers)
    {
        HttpReponseObject rObject = (HttpReponseObject)obj;
        StatusCode = rObject.rStatusCode;
        Response = rObject.rBody;
        Headers = rObject.rHeaders;
    }

    static Dictionary<string, string> ParseHeaders(string iHeaders)
    {
        // Dictionary to store the parsed headers as <string, string>
        var headersDict = new Dictionary<string, string>();

        // Trim leading/trailing spaces or curly braces
        iHeaders = iHeaders.Trim();

        // Ensure the string starts with '{' and ends with '}'
        if (iHeaders.StartsWith("{"))
            iHeaders = iHeaders.Substring(1);
        if (iHeaders.EndsWith("}"))
            iHeaders = iHeaders.Substring(0, iHeaders.Length - 1);

        // Updated regex pattern to allow for optional spaces around the colon
        string pattern = "\"([^\"]+)\"\\s*:\\s*(\"[^\"]*\"|[0-9]+)";
        Regex regex = new Regex(pattern);

        // Find matches using the regex pattern
        MatchCollection matches = regex.Matches(iHeaders);

        foreach (Match match in matches)
        {
            // Extract the key
            string iKey = match.Groups[1].Value;

            // Extract the value (which can be a string or a number)
            string iValue = match.Groups[2].Value;

            // Convert both strings and numbers to string format
            if (iValue.StartsWith("\"") && iValue.EndsWith("\""))
            {
                // If it's a string, remove the surrounding quotes
                iValue = iValue.Trim('"');
            }

            // Add both string and numeric values as strings in the dictionary
            headersDict[iKey] = iValue;
        }

        return headersDict;
    }
}