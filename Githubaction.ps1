$folderName = "Charlie"
$OptFeatureFolderName=""
$apiName = "ContractSystemAPI"

if (!($OptFeatureFolderName.length -eq 0)){$OptFeatureFolderName= "\" + $OptFeatureFolderName}

$virtualpath = "apis\" + $foldername + $OptFeatureFolderName + "\gha" + $apiName

$releasepath = "D:\github_staging\" + "$virtualpath" + "-v0"
$releasepath
if (Test-Path $releasepath){
$measurepath= "D:\github_staging\apis\$folderName$OptFeatureFolderName"
$measure = Get-ChildItem -Path $measurepath -Directory -Filter *gha* | Measure-Object
$count = $measure.count
$split= $releasepath -split "-v"
$releasepath= $split[0] + "-v" + $count
}
dotnet publish -c Release .\ContractProcessTrackingAPI\ContractProcessingSystem_API.sln -o $releasepath
$virtualpath= $virtualpath.replace("\","/")
echo "API-url = `"http://localhost:2021/$virtualpath`""


