[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $ApiKey,
    [Parameter()]
    [string]
    $Version,
    [Parameter()]
    [string]
    $PackageVersion
)

if("$Version" -eq "" -or "$Version" -eq "latest"){
    $response = Invoke-WebRequest -Method GET -Uri "https://github.com/kubernetes/minikube/releases/latest" -MaximumRedirection 0 -SkipHttpErrorCheck  -ErrorAction SilentlyContinue
    $url = "$($response.Links.href)"
    $TargetVersion = $url.Substring( $url.LastIndexOf('/') + 1);
    $TargetVersion = $TargetVersion.Replace('v','').ToLowerInvariant()

}else{
    $TargetVersion = $Version
}
if("$PackageVersion" -eq "" ){
    $PackageVersion = $TargetVersion
}

dotnet pack -p:FileVersion=$TargetVersion -p:Version=$PackageVersion

$pck = "$(Get-ChildItem .\Tocsoft.Minikube.Tool\nupkg\*.nupkg | foreach {$_.FullName } | select -First 1)"
Write-Host "publishing $pck"
if("$ApiKey" -ne "") {
    dotnet nuget push "$pck" --api-key "$ApiKey" --source "https://api.nuget.org/v3/index.json" --skip-duplicate
}else{
    dotnet nuget push "$pck" --source "https://api.nuget.org/v3/index.json" --skip-duplicate
}