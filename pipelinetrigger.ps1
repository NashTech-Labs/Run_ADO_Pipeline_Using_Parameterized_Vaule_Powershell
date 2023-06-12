function GetPipelineParametersValue {
  $pipelineRawUrl = "Enter your file path here  " 
  $pipelineParametersContent = Invoke-WebRequest -Uri $pipelineRawUrl
  $parameterjson= $pipelineParametersContent | ConvertFrom-Json
  return $parameterjson.namespace,  $parameterjson.location    

}


$resourceforADOtrigger = "event-hub" 
$token = " " #Enter your ADO Pipeline PAT Token 
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $token)))



$pipeline_json = " "  #Enter your file path here  
$pipeline_resourceType = $pipeline_json.resources.resourceType
Write-Output $pipeline_resourceType

    if ($pipeline_resourceType -eq $resourceforADOtrigger) {
      Write-Host $resourceforADOtrigger 

     
      $fetchPipelineId = " "  #Enter your file path here  
      | Select-Object -ExpandProperty "resources" `
      | Where-Object {$_.resourceType -eq $resourceforADOtrigger } `
      | Group-Object -Property "pipelineID" `
      | Select-Object -Property Name  | Out-String -NoNewline
   

      $pipelineId = $fetchPipelineId.TrimStart("Name----")
      Write-Host "Type of resource:- $type_of_resource Pipeline ID of resource:-" $pipelineId

      $projectName = "Demo-Eventhub"

      $namespaceParameterValue, $locationParameterValue = GetPipelineParametersValue

      $url = "https://dev.azure.com/hershal8090gupta/$projectName/_apis/pipelines/$pipelineId/runs?api-version=7.0-preview"

      $body = @{
        templateParameters = @{
          namespace      = $namespaceParameterValue
          location       = $locationParameterValue
        }
        resources = @{
          repositories = @{
            self = @{
              refName = "refs/heads/master"
            }
          }
        }
      } | ConvertTo-Json -Depth 3

     $response = Invoke-RestMethod -Method Post -Uri $url -Headers @{Authorization = "Basic $base64AuthInfo" } -ContentType "application/json" -Body $body
    }
