using System;
using System.Data.SqlTypes;
using System.Collections;
using Microsoft.SqlServer.Server;
using System.IO;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;

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

        int rCode = 0;
        string rBody = "";
        string rHeaders = "";

        WebHeaderCollection rDictHeaders = new WebHeaderCollection();
        ArrayList responseCollection = new ArrayList();

        try
        {
            // HTTP method validation
            if (iMethod != "GET" && iMethod != "POST" && iMethod != "PUT" && iMethod != "HEAD" && iMethod != "DELETE" && iMethod != "TRACE" && iMethod != "OPTIONS")
            {
                rBody = "Method not supported. Methods used : " + iMethod + ". List of supported methods : GET, POST, PUT, HEAD, DELETE, TRACE, OPTIONS.";
            }
            // URL validation
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
                // SSL/TLS configuration
                ServicePointManager.SecurityProtocol = (SecurityProtocolType)192 | (SecurityProtocolType)768 | (SecurityProtocolType)3072;

                // Initialiaze HTTP request
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(iUrl);
                request.Method = iMethod;

                // Parse the headers
                try
                {
                    if (iHeaders != "Null" && iHeaders.Length > 0)
                    {
                        var headersDict = ParseJson(iHeaders);

                        // Apply headers
                        foreach (var header in headersDict)
                        {
                            switch (header.Key.ToUpper())
                            {
                                case "ACCEPT":
                                    request.Accept = header.Value;
                                    break;
                                case "CONNECTION":
                                    if (header.Value.ToUpper() == "CLOSE")
                                    {
                                        request.KeepAlive = false;
                                    }
                                    break;
                                case "DATE":
                                    request.Date = DateTime.Parse(header.Value);
                                    break;
                                case "IF-MODIFIED-SINCE":
                                    request.IfModifiedSince = DateTime.Parse(header.Value);
                                    break;
                                case "EXPECT":
                                    request.Expect = header.Value;
                                    break;
                                case "HOST":
                                    request.Host = header.Value;
                                    break;
                                case "REFERER":
                                    request.Referer = header.Value;
                                    break;
                                case "TRANSFER-ENCODING":
                                    request.TransferEncoding = header.Value;
                                    break;
                                case "USER-AGENT":
                                    request.UserAgent = header.Value;
                                    break;
                                case "RANGE":
                                    string[] rangeParts = header.Value.Split('-');
                                    if (rangeParts.Length == 2)
                                    {
                                        request.AddRange(int.Parse(rangeParts[0]), int.Parse(rangeParts[1]));
                                    }
                                    break;
                                case "CONTENT-TYPE":
                                    request.ContentType = header.Value;
                                    break;
                                case "CONTENT-LENGTH":
                                    if (long.TryParse(header.Value, out long contentLength))
                                    {
                                        request.ContentLength = contentLength;
                                    }
                                    break;
                                case "TIMEOUT":
                                    if (int.TryParse(header.Value, out int timeout))
                                    {
                                        request.Timeout = timeout > 0 ? timeout : -1;
                                    }
                                    break;
                                case "VERIFY":
                                    if (header.Value.ToUpper() == "FALSE")
                                    {
                                        request.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;
                                    }
                                    break;
                                default:
                                    if (header.Key.Length > 2)
                                    {
                                        request.Headers.Add(header.Key, header.Value);
                                    }
                                    break;
                            }
                        }
                    }

                    // Handle non-GET requests (POST, PUT, etc.) and write the body
                    if (iMethod != "GET" && iBody.Length > 0 && iBody != "Null")
                    {
                        byte[] byteArray = Encoding.UTF8.GetBytes(iBody);
                        // Set default Content-Type and Content-Length if not already defined
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

                    // Make the HTTP call
                    HttpWebResponse webResponse = (HttpWebResponse)request.GetResponse();
                    StreamReader reader = new StreamReader(webResponse.GetResponseStream());
                    rBody = reader.ReadToEnd();
                    rCode = (int)webResponse.StatusCode;
                    rDictHeaders = webResponse.Headers;
                    webResponse.Close();
                    reader.Close();
                }
                // Handle invalid json header
                catch (FormatException)
                {
                    rBody = "JSON text is not properly formatted. (@headers)";
                }
            }
        }
        // Handle WebExceptions (timeout, SSL errors, ...)
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

        // Format headers into JSON string
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
        // Handle specific error cases like SSL or timeout hints
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

    static Dictionary<string, string> ParseJson(string json)
    {
        // Initialize the dictionnary
        var jsonDict = new Dictionary<string, string>();

        // Trim leading/trailing spaces
        json = json.Trim();

        // Remove the curly braces
        if (json.StartsWith("{") && json.EndsWith("}"))
        {
            json = json.Substring(1);
            json = json.Substring(0, json.Length - 1);
        }
        else
        {
            throw new FormatException("JSON should start with '{' and end with '}'.");
        }

        // regex pattern to parse the JSON key/values 
        Regex regex = new Regex("\"([^\"]+)\"\\s*:\\s*(\"[^\"]*\"|[0-9]+)");

        // Find matches using the regex pattern
        MatchCollection matches = regex.Matches(json);

        foreach (Match match in matches)
        {
            // Key extraction
            string iKey = match.Groups[1].Value;

            // Value extraction (can be a string or a number)
            string iValue = match.Groups[2].Value;

            if (iValue.StartsWith("\"") && iValue.EndsWith("\""))
            {
                // If it's a string, remove the surrounding quotes
                iValue = iValue.Trim('"');
            }

            // Store inside the dictionnary
            jsonDict[iKey] = iValue;
        }

        return jsonDict;
    }
}