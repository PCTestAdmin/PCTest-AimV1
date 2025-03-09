Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class AimAssist {
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);

    [DllImport("user32.dll")]
    public static extern void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);

    private const int MOUSEEVENTF_MOVE = 0x0001;

    public static bool IsLeftMouseButtonPressed() {
        return (GetAsyncKeyState(0x01) & 0x8000) != 0;
    }

    public static void MoveMouse(int x, int y) {
        mouse_event(MOUSEEVENTF_MOVE, x, y, 0, 0);
    }
}
"@ -Language CSharp

# Aim-Assist Funktion mit reduzierter Seitwärtsbewegung
function Start-AimAssist {
    Write-Host "🎯 Aim-Assist läuft... (Drücke F1 zum Beenden)" -ForegroundColor Cyan

    $direction = 1
    $weaponSlot = 2
    $counter = 0  # Zähler für reduzierte seitliche Bewegung

    while ($true) {
        # Beenden mit F1
        if ([AimAssist]::GetAsyncKeyState(0x70) -ne 0) { 
            Write-Host "🔴 Aim-Assist beendet." -ForegroundColor Red
            break
        }

        # Prüfe Waffenslot (1-5)
        for ($i = 1; $i -le 5; $i++) {
            if ([AimAssist]::GetAsyncKeyState(0x30 + $i) -ne 0) {
                $weaponSlot = $i
                Write-Host "🔄 Waffe gewechselt zu Slot $weaponSlot" -ForegroundColor Yellow
                Start-Sleep -Milliseconds 200
            }
        }

        # Bewegung nach unten je nach Waffe
        $moveDown = switch ($weaponSlot) {
            1 { 0 }  # Sniper - kaum Bewegung
            2 { 1 }    # Sturmgewehr - mittlere Bewegung
            3 { 0 }  # Pumpgun - leichte Bewegung
            4 { 1.5 }  # MP - schnellere Bewegung
            5 { 0 }    # Heal - kein Aim-Assist
            default { 1 }
        }

        # Falls linke Maustaste gedrückt wird
        if ([AimAssist]::IsLeftMouseButtonPressed()) {
            [AimAssist]::MoveMouse(0, [math]::Round($moveDown))  # Nur vertikale Bewegung

            # Reduziertes Wackeln: Richtung nur alle 5 Zyklen wechseln
            if ($counter % 5 -eq 0) {
                $direction *= -1
            }
            $counter++

            Start-Sleep -Milliseconds 10
        }
    }
}

# Skript starten
Start-AimAssist
