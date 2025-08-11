Add-Type -AssemblyName PresentationFramework

[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Konserwacja Windows 11 - skrypty CMD/Powershell" Height="500" Width="600">
    <StackPanel Margin="10">
<Button Name="btnSFC" Margin="5">
    <Button.Content>
        <TextBlock TextAlignment="Center" FontFamily="Segoe UI" FontSize="14" FontWeight="Bold">
            <Run Text="SKANUJ SYSTEM W POSZUKIWANIU BŁĘDÓW (SFC/DISM)"/>
            <LineBreak/>
            <Run Text="Wymagany restart systemu"/>
        </TextBlock>
    </Button.Content>
</Button>

<Button Name="btnWMI" Margin="5">
    <Button.Content>
        <TextBlock TextAlignment="Center" FontFamily="Segoe UI" FontSize="14" FontWeight="Bold">
            <Run Text="SKANUJ I NAPRAW REPOZYTORIUM WMI (WINMGMT)"/>
            <LineBreak/>
            <Run Text="Wymagany restart systemu"/>
        </TextBlock>
    </Button.Content>
</Button>

<Button Name="btnNET" Margin="5">
    <Button.Content>
        <TextBlock TextAlignment="Center" FontFamily="Segoe UI" FontSize="14" FontWeight="Bold">
            <Run Text="NAPRAW/ZRESETUJ USTAWIENIA KART SIECIOWYCH (NETSH)"/>
            <LineBreak/>
            <Run Text="Wymagany restart systemu"/>
        </TextBlock>
    </Button.Content>
</Button>

<Button Name="btnIP" Margin="5">
    <Button.Content>
        <TextBlock TextAlignment="Center" FontFamily="Segoe UI" FontSize="14" FontWeight="Bold">
            <Run Text="ODŚWIEŻ ADRES IP I WYCZYŚĆ CACHE DNS (IPCONFIG)"/>
            <LineBreak/>
            <Run Text="Funkcja nie wymaga restartu systemu"/>
        </TextBlock>
    </Button.Content>
</Button>

        <TextBox Name="txtOutput" Height="300" Margin="5" IsReadOnly="True" TextWrapping="Wrap"/>
    </StackPanel>
</Window>
"@

$restartNeeded = $false

$reader=(New-Object System.Xml.XmlNodeReader $XAML)
$Window=[Windows.Markup.XamlReader]::Load($reader)

$Window.FindName("btnSFC").Add_Click({
    $output = cmd /c "sfc /scannow & dism /online /cleanup-image /restorehealth"
    $Window.FindName("txtOutput").Text = $output
    $restartNeeded = $true
})

$Window.FindName("btnNET").Add_Click({
    $output = cmd /c "netsh int ip reset & netsh winsock reset"
    $Window.FindName("txtOutput").Text = $output
    $restartNeeded = $true
})

$Window.FindName("btnWMI").Add_Click({
    $Window.FindName("txtOutput").AppendText("Weryfikacja repozytorium WMI...`r`n")
    $verifyOutput = cmd /c "winmgmt /verifyrepository"
    $Window.FindName("txtOutput").AppendText("$verifyOutput`r`n")

    if ($verifyOutput -match "repository is inconsistent") {
        $Window.FindName("txtOutput").AppendText("Repozytorium WMI jest niespójne. Uruchamiam naprawę...`r`n")
        $repairOutput = cmd /c "winmgmt /salvagerepository"
        $Window.FindName("txtOutput").AppendText("$repairOutput`r`n")
    } else {
        $Window.FindName("txtOutput").AppendText("Repozytorium WMI jest spójne. Nie wymaga naprawy.`r`n")
    }
    $restartNeeded = $true
})

$Window.FindName("btnIP").Add_Click({
    $output = cmd /c "ipconfig /release & ipconfig /flushdns & ipconfig /renew"
    $Window.FindName("txtOutput").Text = $output
})

$Window.Add_Closing({
    if ($restartNeeded) {
        Show-RestartPrompt
    }
})

$Window.ShowDialog()

function Show-RestartPrompt {
    [System.Windows.MessageBox]::Show("Wykonano operacje wymagające restartu systemu.`nZalecany jest restart, aby zmiany zostały w pełni zastosowane.",
                                      "Restart wymagany", "OK", "Information")
}



 