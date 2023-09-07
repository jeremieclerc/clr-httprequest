using System;
using System.Data.SqlTypes;
using System.Collections;
using Microsoft.SqlServer.Server;
using System.IO;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;

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
                rBody = "Method not supported. Methods used : " + iMethod;
            }
            else if (iUrl.Length <= 3 || iUrl.Length > 2000 || iUrl == "Null")
            {
                rBody = "URL not supported. URL Length : " + iUrl.Length + ". URL Value: " + iUrl;
            }
            else
            {
                ServicePointManager.SecurityProtocol = (SecurityProtocolType)192 | (SecurityProtocolType)768 | (SecurityProtocolType)3072;
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(iUrl);
                request.Method = iMethod;


                iHeaders = iHeaders.Trim();
                if (iHeaders.Length > 0 && iHeaders[0] == '{')
                {
                    iHeaders = iHeaders.Remove(0, 1);
                    iHeaders = iHeaders.Remove(iHeaders.Length - 1);
                    iHeaders = Regex.Replace(iHeaders, @"[0-9""],", "$0<StringSplit>");
                    items = iHeaders.Split(new string[] { ",<StringSplit>" }, StringSplitOptions.None);
                }

                foreach (string i in items)
                {
                    string iKey = i.Trim().Substring(0, i.IndexOf(":")).Trim();
                    if (iKey.Length > 2)
                    {
                        iKey = iKey.Substring(1, iKey.Length - 2).Trim();
                    }
                    string iValue = i.Trim().Substring(i.IndexOf(":") + 1).Trim();
                    iValue = Regex.Replace(iValue, @" *, *""$", "");
                    if (iValue.Length > 1 && iValue[0] == '"')
                    {
                        iValue = iValue.Substring(1, iValue.Length - 2).Trim().Replace("\\\"", "\"");
                    }


                    if (String.Equals(iKey, "Accept", StringComparison.OrdinalIgnoreCase))
                    {
                        request.Accept = iValue;
                    }
                    else if (String.Equals(iKey, "Connection", StringComparison.OrdinalIgnoreCase) && String.Equals(iValue, "Close", StringComparison.OrdinalIgnoreCase))
                    {
                        request.KeepAlive = false;
                    }
                    else if (String.Equals(iKey, "Date", StringComparison.OrdinalIgnoreCase))
                    {
                        request.Date = DateTime.Parse(iValue);
                    }
                    else if (String.Equals(iKey, "If-Modified-Since", StringComparison.OrdinalIgnoreCase))
                    {
                        request.IfModifiedSince = DateTime.Parse(iValue);
                    }
                    else if (String.Equals(iKey, "Expect", StringComparison.OrdinalIgnoreCase))
                    {
                        request.Expect = iValue;
                    }
                    else if (String.Equals(iKey, "Host", StringComparison.OrdinalIgnoreCase))
                    {
                        request.Host = iValue;
                    }
                    else if (String.Equals(iKey, "Referer", StringComparison.OrdinalIgnoreCase))
                    {
                        request.Referer = iValue;
                    }
                    else if (String.Equals(iKey, "Transfer-Encoding", StringComparison.OrdinalIgnoreCase))
                    {
                        request.TransferEncoding = iValue;
                    }
                    else if (String.Equals(iKey, "User-Agent", StringComparison.OrdinalIgnoreCase))
                    {
                        request.UserAgent = iValue;
                    }
                    else if (String.Equals(iKey, "Range", StringComparison.OrdinalIgnoreCase))
                    {
                        request.AddRange(int.Parse(iValue.Substring(0, iValue.IndexOf("-") + 1)), int.Parse(iValue.Substring(iValue.IndexOf("-") + 1)));
                    }
                    else if (String.Equals(iKey, "Content-Type", StringComparison.OrdinalIgnoreCase))
                    {
                        request.ContentType = iValue;
                        isContentTypeDefined = true;
                    }
                    else if (String.Equals(iKey, "Content-Length", StringComparison.OrdinalIgnoreCase) && long.TryParse(iValue, out temp))
                    {
                        request.ContentLength = long.Parse(iValue);
                        isContentLengthDefined = true;
                    }
                    else if (String.Equals(iKey, "Timeout", StringComparison.OrdinalIgnoreCase) && long.TryParse(iValue, out temp)) // timeout handle as header
                    {
                        if (int.Parse(iValue) == -1 || int.Parse(iValue) > 0)
                        {
                            request.Timeout = int.Parse(iValue);
                        }
                    }
                    else if (String.Equals(iKey, "Verify", StringComparison.OrdinalIgnoreCase) && String.Equals(iValue, "false", StringComparison.OrdinalIgnoreCase))
                    {
                        request.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;
                    }
                    else if (iKey.Length > 2)
                    {
                        request.Headers.Add(iKey, iValue);
                    }
                }


                if (iMethod != "GET") // POST, PUT etc
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

        responseCollection.Add(new HttpReponseObject(rCode,rBody, rHeaders));
        return responseCollection;
    }

    public static void FillRowHttpRequest(object obj, out SqlInt32 StatusCode, out SqlString Response, out SqlString Headers)
    {
        HttpReponseObject rObject = (HttpReponseObject)obj;
        StatusCode = rObject.rStatusCode;
        Response = rObject.rBody;
        Headers = rObject.rHeaders;
    }
}
