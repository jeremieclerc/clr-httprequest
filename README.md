# Introduction 
Creation of a CLR function capable of making HTTP request

# Getting Started
You need to have : 
- Visual Studio Professional (2016-2022)
- SSDT (SQL Server Data Tools)
- SDK .NET version 7.0 or above (.Net desktop development)
- SQL Server 2014, 2016, 2017, 2019, 2022 or Managed Instance

# Quick Installation
- Execute the file: "AssemblyHttp.sql"

This will create the assembly and the function "HttpRequest" associated.

# Full Installation
- Open the solution with Visual Studio
- Build the assembly
- Load the assembly into SQL Server

# Sources
This procedure have been inspired by this repo:
- https://github.com/eilerth/sqlclr-http-request/blob/master/ClrHttpRequest/clr_http_request.cs

We remove all XML usage and choose JSON instead. Also, we used inline function instead of scalar function.

# Parameters
- The function have 4 mandatory parameters:
  - **Method**: GET, POST, PUT, HEAD, DELETE, TRACE or OPTIONS
  - **Url**: The parameters must be added directly to the url
  - **Headers**: Json dictionary with Key/Value. Can be NULL.
  - **Body**: String. Can be NULL.

# Returns
- The function return 3 columns:
  - **StatusCode**: INT. Ex: 200, 404, 401 etc
  - **Response**: Full response from the website
  - **Headers**: Response headers in Json format

# Example:
```
SELECT TOP 5 b.*
FROM HttpRequest('GET', 'https://restcountries.com/v3.1/all', NULL, NULL) a
CROSS APPLY OPENJSON(Response, '$')
WITH (
	name nvarchar(100) '$.name.common'
	, cca2 char(2)
	, region nvarchar(100)
	, population int
	) b
```
# Results:
|**name**|**cca2**|**region**|**population**|
|---    |:-:    |:-:    |:-:    |
|South Africa|ZA|Africa|59308690|
|Svalbard and Jan Mayen|SJ|Europe|2562|
|Samoa|WS|Oceania|198410|
|Gambia|GM|Africa|2416664|
|Saint Kitts and Nevis|KN|Americas|53192|

# Credit
- Jérémie Clerc
- Oscar Burdin 
