# escape=`

FROM mcr.microsoft.com/dotnet/framework/aspnet:3.5

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV WWWROOT "C:\inetpub\wwwroot"
ENV APPNAME "PLAY"

EXPOSE 80
WORKDIR ${WWWROOT}

RUN Enable-WindowsOptionalFeature -Online -All -FeatureName `
    IIS-ManagementService, `
    IIS-ManagementScriptingTools, `
    IIS-WebServerManagementTools, `
    IIS-HttpCompressionDynamic, `
    IIS-HttpCompressionStatic, `
    IIS-Performance, `
    IIS-URLAuthorization, `
    IIS-WindowsAuthentication, `
    IIS-ASP, `
    IIS-ASPNET, `
    IIS-HttpLogging, `
    IIS-HealthAndDiagnostics, `
    IIS-LoggingLibraries, `
    IIS-HttpTracing, `
    IIS-Security, `
    IIS-RequestFiltering, `
    IIS-StaticContent, `
    IIS-DefaultDocument, `
    IIS-CommonHttpFeatures, `
    IIS-HttpErrors, `
    IIS-HttpRedirect, `
    IIS-ApplicationDevelopment, `
    IIS-WebServerRole, `
    IIS-WebServer, `
    IIS-DirectoryBrowsing

RUN Import-Module WebAdministration; `
    Remove-Website -Name 'Default Web Site' ; `
    # You can not delete DefaultAppPool because it is necessary for remote management
    # Remove-WebAppPool -Name 'DefaultAppPool' ; `
    New-Item -Path IIS:\AppPools\$Env:APPNAME ; `
    Set-ItemProperty -Path IIS:\AppPools\$Env:APPNAME -Name processModel -Value @{identitytype='ApplicationPoolIdentity'} ; `
    New-Website -Name $Env:APPNAME -PhysicalPath $Env:WWWROOT -ApplicationPool $Env:APPNAME -IPAddress '*' -Port 80 -Force ;

##### IIS remote management
RUN Install-WindowsFeature Web-Mgmt-Service ; `
    New-ItemProperty -Path HKLM:\software\microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1 -Force ; `
    Set-Service -Name wmsvc -StartupType automatic ;

RUN net user iisadmin Mirantis1 /ADD ; `
    net localgroup administrators iisadmin /add ;

EXPOSE 8172
#####

EXPOSE 80

COPY PLAY ${WWWROOT}

