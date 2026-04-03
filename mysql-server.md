1. Pull the SQL Server Image
bashdocker pull mcr.microsoft.com/mssql/server:2022-latest
2. Run the Container
bashdocker run -e "ACCEPT_EULA=Y" \
  -e "MSSQL_SA_PASSWORD=YourStrong@Passw0rd" \
  -p 1433:1433 \
  --name sqlserver \
  -d mcr.microsoft.com/mssql/server:2022-latest
Key flags:

-e "ACCEPT_EULA=Y" — required to accept the license
-e "MSSQL_SA_PASSWORD=..." — SA password (min 8 chars, upper + lower + number + symbol)
-p 1433:1433 — maps host port to container port
--name sqlserver — container name
-d — runs in background

3. Verify It's Running
bashdocker ps
4. Connect to SQL Server
Option A — Using sqlcmd inside the container:
bashdocker exec -it sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U SA -P "YourStrong@Passw0rd"
Option B — Using a GUI tool (from your host machine):

Azure Data Studio (free, cross-platform) → connect to localhost,1433
DBeaver → same connection details
SSMS (Windows only)

Connection details:
FieldValueServerlocalhost,1433UsernameSAPasswordYourStrong@Passw0rd
5. Basic sqlcmd Commands
sql-- List databases
SELECT name FROM sys.databases;
GO

-- Create a database
CREATE DATABASE mydb;
GO

-- Use it
USE mydb;
GO

-- Exit
EXIT
6. Persist Data with a Volume (recommended)
bashdocker run -e "ACCEPT_EULA=Y" \
  -e "MSSQL_SA_PASSWORD=YourStrong@Passw0rd" \
  -p 1433:1433 \
  --name sqlserver \
  -v sqlserver_data:/var/opt/mssql \
  -d mcr.microsoft.com/mssql/server:2022-latest
The -v flag mounts a named volume so your data survives container restarts/removal.
7. Useful Docker Commands
bash# Stop the container
docker stop sqlserver

# Start it again
docker start sqlserver

# View logs
docker logs sqlserver

# Remove container
docker rm -f sqlserver
