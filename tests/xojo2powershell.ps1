#############################################################################
# Run PowerShell Command from Clipboard                                     #
#############################################################################

# Get the command from the clipboard
$command = Get-Clipboard

# Check if the clipboard is not empty
if (![string]::IsNullOrWhiteSpace($command)) {
    try {
        # Execute the command and capture the output
        $output = Invoke-Expression $command
        
        # Output the result
        Write-Output $output
    } catch {
        Write-Host "Error executing command: $_"
    }
} else {
    Write-Host "Clipboard is empty or does not contain a valid command."
}