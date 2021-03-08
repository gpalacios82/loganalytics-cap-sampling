Connect-AzAccount

$subscriptions = Get-AzSubscription
foreach ($subscription in $subscriptions) {
    Write-Host "Setting Subscription to: $($subscription.Name)" -BackgroundColor black -ForegroundColor white
    $null = Set-AzContext -Subscription $($subscription.Id)
    $appInsights = Get-AzApplicationInsights

    foreach ($appInsight in $appInsights) {
        Write-Host "Checking App Insights: $($appInsight.Name)"
        $appInsightData = Get-AzApplicationInsights -Name $appInsight.Name -Full -ResourceGroupName $appInsight.ResourceGroupName

        Write-Host "> Setting Daily Cap from $($appInsightData.Cap) to 2"
        $null = Set-AzApplicationInsightsDailyCap -ResourceGroupName $appInsightData.ResourceGroupName -Name $appInsightData.Name -DailyCapGB 2

        Write-Host "> Setting Sampling percentage from $($appInsightData.SamplingPercentage)% to 100%"
        $resource = Get-AzResource -ResourceGroupName $appInsightData.ResourceGroupName -Name $appInsightData.Name -ResourceType Microsoft.Insights/Components 
        $resource.Properties.SamplingPercentage=100
        $null = $resource | Set-AzResource -Force
        Write-Host " "
    }
}
