# powermenu.ps1 - kleines Power-Menue (Shut down, Reboot, Log out, Lock, Sleep)
# Wird von GlazeWM per mod + X gestartet. Tasten: S, R, O, L, P, Esc

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$global:PMChoice = 'cancel'

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Power Menu'
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.ShowInTaskbar = $false
$form.TopMost = $true
$form.KeyPreview = $true
$form.ClientSize = New-Object System.Drawing.Size(260, 290)

$items = @(
    @{ Text = 'Shut down  (S)'; Tag = 'shutdown' },
    @{ Text = 'Reboot  (R)';    Tag = 'reboot' },
    @{ Text = 'Log out  (O)';   Tag = 'logout' },
    @{ Text = 'Lock  (L)';      Tag = 'lock' },
    @{ Text = 'Sleep  (P)';     Tag = 'sleep' },
    @{ Text = 'Cancel  (Esc)';  Tag = 'cancel' }
)

$y = 10
foreach ($item in $items) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $item.Text
    $btn.Tag = $item.Tag
    $btn.Size = New-Object System.Drawing.Size(240, 38)
    $btn.Location = New-Object System.Drawing.Point(10, $y)
    $btn.Add_Click({
        param($s, $e)
        $global:PMChoice = $s.Tag
        $s.FindForm().Close()
    })
    $form.Controls.Add($btn)
    $y += 46
}

$form.Add_KeyDown({
    param($s, $e)
    $map = @{ S = 'shutdown'; R = 'reboot'; O = 'logout'; L = 'lock'; P = 'sleep' }
    $k = $e.KeyCode.ToString()
    if ($k -eq 'Escape') {
        $global:PMChoice = 'cancel'
        $s.Close()
    }
    elseif ($map.ContainsKey($k)) {
        $global:PMChoice = $map[$k]
        $s.Close()
    }
})

$form.Add_Shown({
    param($s, $e)
    $s.Activate()
})

[void]$form.ShowDialog()

switch ($global:PMChoice) {
    'shutdown' { Start-Process shutdown.exe -ArgumentList '/s', '/t', '0' -WindowStyle Hidden }
    'reboot'   { Start-Process shutdown.exe -ArgumentList '/r', '/t', '0' -WindowStyle Hidden }
    'logout'   { Start-Process shutdown.exe -ArgumentList '/l' -WindowStyle Hidden }
    'lock'     { Start-Process rundll32.exe -ArgumentList 'user32.dll,LockWorkStation' }
    'sleep'    { [void][System.Windows.Forms.Application]::SetSuspendState('Suspend', $false, $false) }
    default    { }
}
