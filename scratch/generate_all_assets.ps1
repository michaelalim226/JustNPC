Add-Type -AssemblyName System.Drawing

$baseDir = "c:\Users\LENOVO\Videos\Game Projek\npcdayoff"
$spritesDir = Join-Path $baseDir "assets\sprites"
$audioDir = Join-Path $baseDir "assets\audio"

[System.IO.Directory]::CreateDirectory($spritesDir) | Out-Null
[System.IO.Directory]::CreateDirectory($audioDir) | Out-Null

function Save-PixelBitmap {
    param(
        [string]$Path,
        [int]$Width,
        [int]$Height,
        [scriptblock]$DrawBlock
    )
    $bmp = New-Object System.Drawing.Bitmap $Width, $Height
    & $DrawBlock $bmp
    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Output "Generated: $Path"
}

# --- 1. PLAYER SPRITES ---
# Player Idle (32x32)
Save-PixelBitmap -Path (Join-Path $spritesDir "player_idle.png") -Width 32 -Height 32 -DrawBlock {
    param($bmp)
    $cSkin = [System.Drawing.Color]::FromArgb(255, 235, 195, 155)
    $cHair = [System.Drawing.Color]::FromArgb(255, 110, 65, 30)
    $cShirt = [System.Drawing.Color]::FromArgb(255, 55, 110, 180)
    $cPants = [System.Drawing.Color]::FromArgb(255, 60, 50, 45)
    $cBoots = [System.Drawing.Color]::FromArgb(255, 40, 30, 20)
    $cEye = [System.Drawing.Color]::FromArgb(255, 35, 35, 40)
    $cShadow = [System.Drawing.Color]::FromArgb(255, 45, 90, 150)
    $cOutline = [System.Drawing.Color]::FromArgb(255, 20, 20, 25)

    # Hair / Head
    for ($x=11; $x -le 20; $x++) { for ($y=5; $y -le 9; $y++) { $bmp.SetPixel($x, $y, $cHair) } }
    for ($x=10; $x -le 21; $x++) { for ($y=9; $y -le 15; $y++) { $bmp.SetPixel($x, $y, $cSkin) } }
    # Hair strands
    $bmp.SetPixel(10, 8, $cHair); $bmp.SetPixel(21, 8, $cHair); $bmp.SetPixel(12, 10, $cHair); $bmp.SetPixel(19, 10, $cHair)
    
    # Tired eyes (-_-)
    $bmp.SetPixel(12, 12, $cEye); $bmp.SetPixel(13, 12, $cEye); $bmp.SetPixel(14, 12, $cEye)
    $bmp.SetPixel(17, 12, $cEye); $bmp.SetPixel(18, 12, $cEye); $bmp.SetPixel(19, 12, $cEye)
    # Eyebrows droopy/bored
    $bmp.SetPixel(12, 11, $cHair); $bmp.SetPixel(19, 11, $cHair)
    # Neutral/bored mouth
    $bmp.SetPixel(15, 14, $cOutline); $bmp.SetPixel(16, 14, $cOutline)

    # Body / Tunic
    for ($x=10; $x -le 21; $x++) { for ($y=16; $y -le 23; $y++) { $bmp.SetPixel($x, $y, $cShirt) } }
    for ($x=10; $x -le 21; $x++) { $bmp.SetPixel($x, 23, $cShadow) } # belt/hem
    for ($y=16; $y -le 21; $y++) { $bmp.SetPixel(9, $y, $cShirt); $bmp.SetPixel(22, $y, $cShirt) } # arms
    $bmp.SetPixel(9, 22, $cSkin); $bmp.SetPixel(22, 22, $cSkin) # hands

    # Pants & Boots
    for ($x=11; $x -le 14; $x++) { for ($y=24; $y -le 27; $y++) { $bmp.SetPixel($x, $y, $cPants) } }
    for ($x=17; $x -le 20; $x++) { for ($y=24; $y -le 27; $y++) { $bmp.SetPixel($x, $y, $cPants) } }
    for ($x=11; $x -le 14; $x++) { for ($y=28; $y -le 29; $y++) { $bmp.SetPixel($x, $y, $cBoots) } }
    for ($x=17; $x -le 20; $x++) { for ($y=28; $y -le 29; $y++) { $bmp.SetPixel($x, $y, $cBoots) } }
}

# Player Walk (32x32)
Save-PixelBitmap -Path (Join-Path $spritesDir "player_walk.png") -Width 32 -Height 32 -DrawBlock {
    param($bmp)
    $cSkin = [System.Drawing.Color]::FromArgb(255, 235, 195, 155)
    $cHair = [System.Drawing.Color]::FromArgb(255, 110, 65, 30)
    $cShirt = [System.Drawing.Color]::FromArgb(255, 55, 110, 180)
    $cPants = [System.Drawing.Color]::FromArgb(255, 60, 50, 45)
    $cBoots = [System.Drawing.Color]::FromArgb(255, 40, 30, 20)
    $cEye = [System.Drawing.Color]::FromArgb(255, 35, 35, 40)
    $cOutline = [System.Drawing.Color]::FromArgb(255, 20, 20, 25)

    for ($x=11; $x -le 20; $x++) { for ($y=5; $y -le 9; $y++) { $bmp.SetPixel($x, $y, $cHair) } }
    for ($x=10; $x -le 21; $x++) { for ($y=9; $y -le 15; $y++) { $bmp.SetPixel($x, $y, $cSkin) } }
    $bmp.SetPixel(12, 12, $cEye); $bmp.SetPixel(13, 12, $cEye); $bmp.SetPixel(14, 12, $cEye)
    $bmp.SetPixel(17, 12, $cEye); $bmp.SetPixel(18, 12, $cEye); $bmp.SetPixel(19, 12, $cEye)
    $bmp.SetPixel(15, 14, $cOutline); $bmp.SetPixel(16, 14, $cOutline)

    for ($x=10; $x -le 21; $x++) { for ($y=16; $y -le 23; $y++) { $bmp.SetPixel($x, $y, $cShirt) } }
    $bmp.SetPixel(8, 17, $cShirt); $bmp.SetPixel(8, 18, $cShirt); $bmp.SetPixel(8, 19, $cSkin)
    $bmp.SetPixel(23, 19, $cShirt); $bmp.SetPixel(23, 20, $cShirt); $bmp.SetPixel(23, 21, $cSkin)

    # Stride legs
    for ($x=9; $x -le 12; $x++) { for ($y=24; $y -le 27; $y++) { $bmp.SetPixel($x, $y, $cPants) } }
    for ($x=9; $x -le 12; $x++) { for ($y=28; $y -le 29; $y++) { $bmp.SetPixel($x, $y, $cBoots) } }
    for ($x=19; $x -le 22; $x++) { for ($y=24; $y -le 27; $y++) { $bmp.SetPixel($x, $y, $cPants) } }
    for ($x=19; $x -le 22; $x++) { for ($y=28; $y -le 29; $y++) { $bmp.SetPixel($x, $y, $cBoots) } }
}

# --- 2. SECONDARY NPCS ---
# NPC Villager (32x32)
Save-PixelBitmap -Path (Join-Path $spritesDir "npc_villager.png") -Width 32 -Height 32 -DrawBlock {
    param($bmp)
    $cSkin = [System.Drawing.Color]::FromArgb(255, 240, 200, 160)
    $cHair = [System.Drawing.Color]::FromArgb(255, 160, 110, 40)
    $cShirt = [System.Drawing.Color]::FromArgb(255, 60, 150, 70)
    $cVest = [System.Drawing.Color]::FromArgb(255, 130, 80, 40)
    $cPants = [System.Drawing.Color]::FromArgb(255, 70, 60, 50)
    $cBoots = [System.Drawing.Color]::FromArgb(255, 50, 40, 30)
    $cEye = [System.Drawing.Color]::FromArgb(255, 30, 30, 30)

    for ($x=11; $x -le 20; $x++) { for ($y=5; $y -le 8; $y++) { $bmp.SetPixel($x, $y, $cHair) } }
    for ($x=10; $x -le 21; $x++) { for ($y=9; $y -le 15; $y++) { $bmp.SetPixel($x, $y, $cSkin) } }
    $bmp.SetPixel(13, 12, $cEye); $bmp.SetPixel(18, 12, $cEye)
    $bmp.SetPixel(15, 14, [System.Drawing.Color]::FromArgb(255, 180, 70, 70))
    for ($x=10; $x -le 21; $x++) { for ($y=16; $y -le 23; $y++) { $bmp.SetPixel($x, $y, $cShirt) } }
    for ($y=16; $y -le 23; $y++) { $bmp.SetPixel(10, $y, $cVest); $bmp.SetPixel(11, $y, $cVest); $bmp.SetPixel(20, $y, $cVest); $bmp.SetPixel(21, $y, $cVest) }
    for ($x=11; $x -le 14; $x++) { for ($y=24; $y -le 29; $y++) { $bmp.SetPixel($x, $y, $cPants) } }
    for ($x=17; $x -le 20; $x++) { for ($y=24; $y -le 29; $y++) { $bmp.SetPixel($x, $y, $cPants) } }
}

# NPC Farmer (32x32)
Save-PixelBitmap -Path (Join-Path $spritesDir "npc_farmer.png") -Width 32 -Height 32 -DrawBlock {
    param($bmp)
    $cSkin = [System.Drawing.Color]::FromArgb(255, 230, 185, 145)
    $cHat = [System.Drawing.Color]::FromArgb(255, 220, 190, 90)
    $cHatRibbon = [System.Drawing.Color]::FromArgb(255, 170, 50, 40)
    $cShirt = [System.Drawing.Color]::FromArgb(255, 200, 70, 50)
    $cOveralls = [System.Drawing.Color]::FromArgb(255, 45, 80, 140)
    $cEye = [System.Drawing.Color]::FromArgb(255, 30, 30, 30)

    # Straw Hat
    for ($x=7; $x -le 24; $x++) { $bmp.SetPixel($x, 7, $cHat) }
    for ($x=10; $x -le 21; $x++) { for ($y=4; $y -le 6; $y++) { $bmp.SetPixel($x, $y, $cHat) } }
    for ($x=10; $x -le 21; $x++) { $bmp.SetPixel($x, 6, $cHatRibbon) }
    # Face
    for ($x=10; $x -le 21; $x++) { for ($y=8; $y -le 14; $y++) { $bmp.SetPixel($x, $y, $cSkin) } }
    $bmp.SetPixel(13, 11, $cEye); $bmp.SetPixel(18, 11, $cEye)
    # Beard
    for ($x=12; $x -le 19; $x++) { $bmp.SetPixel($x, 14, [System.Drawing.Color]::FromArgb(255, 120, 120, 120)) }
    # Body with overalls
    for ($x=10; $x -le 21; $x++) { for ($y=15; $y -le 23; $y++) { $bmp.SetPixel($x, $y, $cShirt) } }
    for ($x=11; $x -le 20; $x++) { for ($y=18; $y -le 27; $y++) { $bmp.SetPixel($x, $y, $cOveralls) } }
    $bmp.SetPixel(12, 16, $cOveralls); $bmp.SetPixel(12, 17, $cOveralls); $bmp.SetPixel(19, 16, $cOveralls); $bmp.SetPixel(19, 17, $cOveralls)
}

# --- 3. MEMORY FRAGMENT CRYSTAL (32x32) ---
Save-PixelBitmap -Path (Join-Path $spritesDir "memory_fragment.png") -Width 32 -Height 32 -DrawBlock {
    param($bmp)
    $cCore = [System.Drawing.Color]::FromArgb(255, 240, 255, 255)
    $cBright = [System.Drawing.Color]::FromArgb(255, 80, 230, 255)
    $cMid = [System.Drawing.Color]::FromArgb(255, 20, 160, 240)
    $cDeep = [System.Drawing.Color]::FromArgb(255, 10, 80, 180)
    $cGlow = [System.Drawing.Color]::FromArgb(120, 60, 210, 255)
    $cSparkle = [System.Drawing.Color]::FromArgb(255, 255, 255, 220)

    # Crystal Diamond Shape
    $coords = @(
        @(15,6),(16,6),
        @(13,8),(14,8),(15,8),(16,8),(17,8),(18,8),
        @(11,11),(12,11),(13,11),(14,11),(15,11),(16,11),(17,11),(18,11),(19,11),(20,11),
        @(12,14),(13,14),(14,14),(15,14),(16,14),(17,14),(18,14),(19,14),
        @(13,17),(14,17),(15,17),(16,17),(17,17),(18,17),
        @(14,20),(15,20),(16,20),(17,20),
        @(15,23),(16,23),
        @(15,25),(16,25)
    )
    for ($y=6; $y -le 25; $y++) {
        $halfW = 0
        if ($y -le 12) { $halfW = [math]::Floor(($y - 5) * 1.0) }
        else { $halfW = [math]::Floor((26 - $y) * 0.55) }
        for ($x=(15-$halfW); $x -le (16+$halfW); $x++) {
            $col = $cMid
            if ($x -ge 14 -and $x -le 16 -and $y -ge 10 -and $y -le 18) { $col = $cCore }
            elseif ($x -lt 15) { $col = $cBright }
            else { $col = $cDeep }
            $bmp.SetPixel($x, $y, $col)
        }
    }
    # Sparkle stars
    $bmp.SetPixel(7, 9, $cSparkle); $bmp.SetPixel(8, 9, $cSparkle); $bmp.SetPixel(7, 8, $cSparkle); $bmp.SetPixel(7, 10, $cSparkle)
    $bmp.SetPixel(23, 21, $cSparkle); $bmp.SetPixel(24, 21, $cSparkle); $bmp.SetPixel(23, 20, $cSparkle); $bmp.SetPixel(23, 22, $cSparkle)
}

# --- 4. GATES (64x64) ---
# Gate Closed
Save-PixelBitmap -Path (Join-Path $spritesDir "gate_closed.png") -Width 64 -Height 64 -DrawBlock {
    param($bmp)
    $cStone = [System.Drawing.Color]::FromArgb(255, 90, 95, 105)
    $cStoneDark = [System.Drawing.Color]::FromArgb(255, 55, 60, 70)
    $cStoneLight = [System.Drawing.Color]::FromArgb(255, 140, 145, 155)
    $cWood = [System.Drawing.Color]::FromArgb(255, 110, 65, 35)
    $cIron = [System.Drawing.Color]::FromArgb(255, 45, 45, 50)
    $cRuneOff = [System.Drawing.Color]::FromArgb(255, 75, 80, 85)

    # Stone Pillars (Left & Right)
    for ($y=8; $y -le 60; $y++) {
        for ($x=6; $x -le 18; $x++) { $bmp.SetPixel($x, $y, $cStone) }
        for ($x=45; $x -le 57; $x++) { $bmp.SetPixel($x, $y, $cStone) }
        $bmp.SetPixel(6, $y, $cStoneLight); $bmp.SetPixel(18, $y, $cStoneDark)
        $bmp.SetPixel(45, $y, $cStoneLight); $bmp.SetPixel(57, $y, $cStoneDark)
    }
    # Top Stone Arch
    for ($x=6; $x -le 57; $x++) {
        for ($y=6; $y -le 18; $y++) { $bmp.SetPixel($x, $y, $cStone) }
        $bmp.SetPixel($x, 6, $cStoneLight); $bmp.SetPixel($x, 18, $cStoneDark)
    }
    # Carved Inactive Runes
    $bmp.SetPixel(12, 25, $cRuneOff); $bmp.SetPixel(12, 35, $cRuneOff); $bmp.SetPixel(12, 45, $cRuneOff)
    $bmp.SetPixel(51, 25, $cRuneOff); $bmp.SetPixel(51, 35, $cRuneOff); $bmp.SetPixel(51, 45, $cRuneOff)
    $bmp.SetPixel(31, 12, $cRuneOff); $bmp.SetPixel(32, 12, $cRuneOff)

    # Locked Wooden Door with Iron Bars
    for ($x=19; $x -le 44; $x++) {
        for ($y=19; $y -le 60; $y++) {
            $bmp.SetPixel($x, $y, $cWood)
        }
    }
    # Iron reinforcements and padlock
    for ($x=19; $x -le 44; $x++) {
        $bmp.SetPixel($x, 28, $cIron); $bmp.SetPixel($x, 48, $cIron)
    }
    for ($x=29; $x -le 34; $x++) {
        for ($y=36; $y -le 42; $y++) { $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 200, 160, 30)) }
    }
}

# Gate Open / Glowing (64x64)
Save-PixelBitmap -Path (Join-Path $spritesDir "gate_open.png") -Width 64 -Height 64 -DrawBlock {
    param($bmp)
    $cStone = [System.Drawing.Color]::FromArgb(255, 90, 95, 105)
    $cStoneDark = [System.Drawing.Color]::FromArgb(255, 55, 60, 70)
    $cStoneLight = [System.Drawing.Color]::FromArgb(255, 140, 145, 155)
    $cRuneGlow = [System.Drawing.Color]::FromArgb(255, 80, 240, 255)
    $cPortalCore = [System.Drawing.Color]::FromArgb(255, 240, 255, 255)
    $cPortalMid = [System.Drawing.Color]::FromArgb(255, 40, 190, 240)
    $cPortalDeep = [System.Drawing.Color]::FromArgb(255, 15, 60, 160)

    # Pillars
    for ($y=8; $y -le 60; $y++) {
        for ($x=6; $x -le 18; $x++) { $bmp.SetPixel($x, $y, $cStone) }
        for ($x=45; $x -le 57; $x++) { $bmp.SetPixel($x, $y, $cStone) }
        $bmp.SetPixel(6, $y, $cStoneLight); $bmp.SetPixel(18, $y, $cStoneDark)
        $bmp.SetPixel(45, $y, $cStoneLight); $bmp.SetPixel(57, $y, $cStoneDark)
    }
    # Arch
    for ($x=6; $x -le 57; $x++) {
        for ($y=6; $y -le 18; $y++) { $bmp.SetPixel($x, $y, $cStone) }
        $bmp.SetPixel($x, 6, $cStoneLight); $bmp.SetPixel($x, 18, $cStoneDark)
    }
    # Glowing Runes
    $bmp.SetPixel(12, 25, $cRuneGlow); $bmp.SetPixel(12, 35, $cRuneGlow); $bmp.SetPixel(12, 45, $cRuneGlow)
    $bmp.SetPixel(51, 25, $cRuneGlow); $bmp.SetPixel(51, 35, $cRuneGlow); $bmp.SetPixel(51, 45, $cRuneGlow)
    $bmp.SetPixel(31, 12, $cRuneGlow); $bmp.SetPixel(32, 12, $cRuneGlow)

    # Swirling Portal in the Middle
    for ($x=19; $x -le 44; $x++) {
        for ($y=19; $y -le 60; $y++) {
            $dx = $x - 31.5; $dy = $y - 39.5
            $dist = [math]::Sqrt($dx*$dx + $dy*$dy)
            if ($dist -lt 7) { $bmp.SetPixel($x, $y, $cPortalCore) }
            elseif ($dist -lt 13) { $bmp.SetPixel($x, $y, $cPortalMid) }
            else { $bmp.SetPixel($x, $y, $cPortalDeep) }
        }
    }
}

# --- 5. ENVIRONMENT: TREE, HOUSE, ROCK, GROUND ---
# RPG Tree (64x80)
Save-PixelBitmap -Path (Join-Path $spritesDir "tree.png") -Width 64 -Height 80 -DrawBlock {
    param($bmp)
    $cTrunk = [System.Drawing.Color]::FromArgb(255, 100, 60, 30)
    $cTrunkDark = [System.Drawing.Color]::FromArgb(255, 60, 35, 18)
    $cLeafLight = [System.Drawing.Color]::FromArgb(255, 95, 185, 65)
    $cLeafMid = [System.Drawing.Color]::FromArgb(255, 55, 140, 45)
    $cLeafDark = [System.Drawing.Color]::FromArgb(255, 30, 85, 30)

    # Trunk
    for ($y=46; $y -le 76; $y++) {
        $w = 6 + [math]::Floor(($y - 46) * 0.25)
        for ($x=(32-$w); $x -le (32+$w); $x++) {
            $col = if ($x -gt 32) { $cTrunkDark } else { $cTrunk }
            $bmp.SetPixel($x, $y, $col)
        }
    }
    # Canopy (3 overlapping circular foliage blobs)
    $blobs = @(
        @{ cx=32; cy=30; r=24 },
        @{ cx=22; cy=38; r=18 },
        @{ cx=42; cy=38; r=18 }
    )
    foreach ($b in $blobs) {
        for ($x=0; $x -lt 64; $x++) {
            for ($y=0; $y -lt 80; $y++) {
                $dist = [math]::Sqrt(($x - $b.cx)*($x - $b.cx) + ($y - $b.cy)*($y - $b.cy))
                if ($dist -le $b.r) {
                    if ($dist -le ($b.r * 0.5) -and $y -lt $b.cy) { $bmp.SetPixel($x, $y, $cLeafLight) }
                    elseif ($dist -le ($b.r * 0.85) -and $x -lt ($b.cx + 4)) { $bmp.SetPixel($x, $y, $cLeafMid) }
                    else { $bmp.SetPixel($x, $y, $cLeafDark) }
                }
            }
        }
    }
}

# Small Tree / Pine (48x64)
Save-PixelBitmap -Path (Join-Path $spritesDir "tree_small.png") -Width 48 -Height 64 -DrawBlock {
    param($bmp)
    $cTrunk = [System.Drawing.Color]::FromArgb(255, 90, 50, 25)
    $cLeafLight = [System.Drawing.Color]::FromArgb(255, 80, 160, 60)
    $cLeafMid = [System.Drawing.Color]::FromArgb(255, 45, 120, 45)
    $cLeafDark = [System.Drawing.Color]::FromArgb(255, 25, 75, 30)

    for ($y=40; $y -le 60; $y++) {
        for ($x=21; $x -le 26; $x++) { $bmp.SetPixel($x, $y, $cTrunk) }
    }
    for ($tier=0; $tier -lt 3; $tier++) {
        $topY = 8 + ($tier * 12)
        $h = 16
        for ($y=$topY; $y -le ($topY + $h); $y++) {
            $w = [math]::Floor(($y - $topY) * 1.1) + ($tier * 2)
            for ($x=(24-$w); $x -le (24+$w); $x++) {
                if ($x -ge 0 -and $x -lt 48) {
                    $col = if ($x -lt 24) { $cLeafLight } elseif ($y -gt ($topY + 8)) { $cLeafDark } else { $cLeafMid }
                    $bmp.SetPixel($x, $y, $col)
                }
            }
        }
    }
}

# RPG Cottage / House (96x80)
Save-PixelBitmap -Path (Join-Path $spritesDir "house.png") -Width 96 -Height 80 -DrawBlock {
    param($bmp)
    $cWall = [System.Drawing.Color]::FromArgb(255, 220, 205, 180)
    $cWallShadow = [System.Drawing.Color]::FromArgb(255, 175, 160, 135)
    $cTimber = [System.Drawing.Color]::FromArgb(255, 100, 60, 30)
    $cRoofLight = [System.Drawing.Color]::FromArgb(255, 190, 65, 45)
    $cRoofDark = [System.Drawing.Color]::FromArgb(255, 135, 40, 25)
    $cWindow = [System.Drawing.Color]::FromArgb(255, 255, 225, 110)
    $cDoor = [System.Drawing.Color]::FromArgb(255, 120, 75, 35)
    $cStoneBase = [System.Drawing.Color]::FromArgb(255, 110, 115, 125)

    # Chimney
    for ($x=68; $x -le 78; $x++) { for ($y=8; $y -le 26; $y++) { $bmp.SetPixel($x, $y, $cStoneBase) } }
    # Roof (Triangle / Gable)
    for ($y=16; $y -le 46; $y++) {
        $w = [math]::Floor(($y - 16) * 1.5) + 3
        for ($x=(48-$w); $x -le (48+$w); $x++) {
            if ($x -ge 4 -and $x -le 91) {
                $col = if ($x -le 48) { $cRoofLight } else { $cRoofDark }
                $bmp.SetPixel($x, $y, $col)
            }
        }
    }
    # Walls
    for ($y=47; $y -le 75; $y++) {
        for ($x=14; $x -le 81; $x++) {
            $col = if ($y -ge 71) { $cStoneBase } elseif ($x -ge 50) { $cWallShadow } else { $cWall }
            $bmp.SetPixel($x, $y, $col)
        }
    }
    # Timber Framing
    for ($y=47; $y -le 75; $y++) {
        $bmp.SetPixel(14, $y, $cTimber); $bmp.SetPixel(15, $y, $cTimber)
        $bmp.SetPixel(80, $y, $cTimber); $bmp.SetPixel(81, $y, $cTimber)
        $bmp.SetPixel(47, $y, $cTimber); $bmp.SetPixel(48, $y, $cTimber)
    }
    # Door
    for ($x=24; $x -le 38; $x++) {
        for ($y=56; $y -le 75; $y++) { $bmp.SetPixel($x, $y, $cDoor) }
    }
    $bmp.SetPixel(36, 66, [System.Drawing.Color]::FromArgb(255, 230, 190, 50)) # Knob
    # Glowing Windows
    for ($x=56; $x -le 70; $x++) {
        for ($y=54; $y -le 66; $y++) { $bmp.SetPixel($x, $y, $cWindow) }
    }
    for ($x=56; $x -le 70; $x++) { $bmp.SetPixel($x, 60, $cTimber) }
    for ($y=54; $y -le 66; $y++) { $bmp.SetPixel(63, $y, $cTimber) }
}

# Mossy Rock (32x32)
Save-PixelBitmap -Path (Join-Path $spritesDir "rock.png") -Width 32 -Height 32 -DrawBlock {
    param($bmp)
    $cStoneLight = [System.Drawing.Color]::FromArgb(255, 145, 150, 160)
    $cStoneMid = [System.Drawing.Color]::FromArgb(255, 100, 105, 115)
    $cStoneDark = [System.Drawing.Color]::FromArgb(255, 60, 65, 75)
    $cMoss = [System.Drawing.Color]::FromArgb(255, 75, 140, 50)

    for ($y=10; $y -le 26; $y++) {
        $w = 12 - [math]::Abs($y - 18) * 0.8
        for ($x=(16-[math]::Floor($w)); $x -le (16+[math]::Floor($w)); $x++) {
            $col = $cStoneMid
            if ($x -lt 14 -and $y -lt 18) { $col = $cStoneLight }
            elseif ($x -gt 18 -or $y -gt 22) { $col = $cStoneDark }
            $bmp.SetPixel($x, $y, $col)
        }
    }
    # Moss on top
    $bmp.SetPixel(12, 11, $cMoss); $bmp.SetPixel(13, 11, $cMoss); $bmp.SetPixel(14, 12, $cMoss); $bmp.SetPixel(15, 11, $cMoss)
    $bmp.SetPixel(16, 12, $cMoss); $bmp.SetPixel(17, 12, $cMoss); $bmp.SetPixel(18, 13, $cMoss)
}

# Ground Grass (64x64 seamless)
Save-PixelBitmap -Path (Join-Path $spritesDir "ground_grass.png") -Width 64 -Height 64 -DrawBlock {
    param($bmp)
    $cBase = [System.Drawing.Color]::FromArgb(255, 72, 132, 54)
    $cLight = [System.Drawing.Color]::FromArgb(255, 88, 155, 65)
    $cDark = [System.Drawing.Color]::FromArgb(255, 58, 110, 42)
    $cFlower1 = [System.Drawing.Color]::FromArgb(255, 245, 230, 90)
    $cFlower2 = [System.Drawing.Color]::FromArgb(255, 240, 110, 150)

    for ($x=0; $x -lt 64; $x++) {
        for ($y=0; $y -lt 64; $y++) {
            $noise = (($x * 7 + $y * 13 + ($x * $y * 3)) % 10)
            if ($noise -eq 0) { $bmp.SetPixel($x, $y, $cLight) }
            elseif ($noise -eq 1) { $bmp.SetPixel($x, $y, $cDark) }
            else { $bmp.SetPixel($x, $y, $cBase) }
        }
    }
    # Little flowers
    $bmp.SetPixel(12, 18, $cFlower1); $bmp.SetPixel(44, 10, $cFlower2); $bmp.SetPixel(28, 48, $cFlower1); $bmp.SetPixel(52, 50, $cFlower2)
}

# Ground Path / Cobblestone (64x64)
Save-PixelBitmap -Path (Join-Path $spritesDir "ground_path.png") -Width 64 -Height 64 -DrawBlock {
    param($bmp)
    $cDirt = [System.Drawing.Color]::FromArgb(255, 140, 110, 75)
    $cStone1 = [System.Drawing.Color]::FromArgb(255, 170, 155, 135)
    $cStone2 = [System.Drawing.Color]::FromArgb(255, 130, 115, 100)
    $cStoneDark = [System.Drawing.Color]::FromArgb(255, 95, 80, 65)

    for ($x=0; $x -lt 64; $x++) {
        for ($y=0; $y -lt 64; $y++) {
            $bmp.SetPixel($x, $y, $cDirt)
        }
    }
    # Cobblestone grid
    for ($gx=4; $gx -lt 60; $gx+=14) {
        for ($gy=4; $gy -lt 60; $gy+=14) {
            $ox = if ($gy % 28 -eq 0) { 0 } else { 7 }
            $px = ($gx + $ox) % 56 + 4
            for ($ix=0; $ix -le 9; $ix++) {
                for ($iy=0; $iy -le 9; $iy++) {
                    $col = if ($ix -eq 0 -or $iy -eq 0) { $cStone1 } elseif ($ix -eq 9 -or $iy -eq 9) { $cStoneDark } else { $cStone2 }
                    $bmp.SetPixel(($px + $ix), ($gy + $iy), $col)
                }
            }
        }
    }
}

# --- 6. UI PORTRAITS & ICONS ---
# NPC Bored Portrait (64x64)
Save-PixelBitmap -Path (Join-Path $spritesDir "portrait_npc.png") -Width 64 -Height 64 -DrawBlock {
    param($bmp)
    $cBg = [System.Drawing.Color]::FromArgb(255, 30, 35, 45)
    $cSkin = [System.Drawing.Color]::FromArgb(255, 235, 195, 155)
    $cHair = [System.Drawing.Color]::FromArgb(255, 110, 65, 30)
    $cShirt = [System.Drawing.Color]::FromArgb(255, 55, 110, 180)
    $cEye = [System.Drawing.Color]::FromArgb(255, 25, 25, 30)

    for ($x=0; $x -lt 64; $x++) { for ($y=0; $y -lt 64; $y++) { $bmp.SetPixel($x, $y, $cBg) } }
    # Head & Hair
    for ($x=18; $x -le 46; $x++) { for ($y=12; $y -le 24; $y++) { $bmp.SetPixel($x, $y, $cHair) } }
    for ($x=16; $x -le 48; $x++) { for ($y=22; $y -le 46; $y++) { $bmp.SetPixel($x, $y, $cSkin) } }
    # Messy hair locks
    $bmp.SetPixel(16, 20, $cHair); $bmp.SetPixel(48, 20, $cHair); $bmp.SetPixel(22, 26, $cHair); $bmp.SetPixel(42, 26, $cHair)

    # Super tired, bored eyes (-_-)
    for ($x=20; $x -le 28; $x++) { $bmp.SetPixel($x, 32, $cEye); $bmp.SetPixel($x, 33, $cEye) }
    for ($x=36; $x -le 44; $x++) { $bmp.SetPixel($x, 32, $cEye); $bmp.SetPixel($x, 33, $cEye) }
    # Droopy eye bags
    for ($x=22; $x -le 28; $x++) { $bmp.SetPixel($x, 36, [System.Drawing.Color]::FromArgb(255, 195, 155, 125)) }
    for ($x=36; $x -le 42; $x++) { $bmp.SetPixel($x, 36, [System.Drawing.Color]::FromArgb(255, 195, 155, 125)) }
    # Bored flat mouth
    for ($x=28; $x -le 36; $x++) { $bmp.SetPixel($x, 42, $cEye) }
    # Shoulders
    for ($x=8; $x -le 56; $x++) { for ($y=48; $y -le 63; $y++) { $bmp.SetPixel($x, $y, $cShirt) } }
}

# Item Icon UI (32x32)
Save-PixelBitmap -Path (Join-Path $spritesDir "item_icon.png") -Width 32 -Height 32 -DrawBlock {
    param($bmp)
    $cBright = [System.Drawing.Color]::FromArgb(255, 80, 235, 255)
    $cMid = [System.Drawing.Color]::FromArgb(255, 20, 160, 240)
    $cCore = [System.Drawing.Color]::FromArgb(255, 250, 255, 255)

    for ($y=4; $y -le 27; $y++) {
        $halfW = if ($y -le 14) { ($y - 4) } else { (28 - $y) * 0.7 }
        for ($x=(16-[math]::Floor($halfW)); $x -le (16+[math]::Floor($halfW)); $x++) {
            $col = if ($x -ge 14 -and $x -le 18) { $cCore } elseif ($x -lt 16) { $cBright } else { $cMid }
            $bmp.SetPixel($x, $y, $col)
        }
    }
}

# --- 7. SYNTHESIZE WAV AUDIO FILES ---
function Write-WavFile {
    param(
        [string]$Path,
        [int]$SampleRate = 22050,
        [scriptblock]$GenerateSamples
    )
    $samples = & $GenerateSamples $SampleRate
    $numSamples = $samples.Count
    $byteRate = $SampleRate * 2 # 16-bit mono
    $subChunk2Size = $numSamples * 2
    $chunkSize = 36 + $subChunk2Size

    $stream = [System.IO.File]::Create($Path)
    $writer = New-Object System.IO.BinaryWriter $stream

    # RIFF header
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes("RIFF"))
    $writer.Write([int]$chunkSize)
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes("WAVE"))

    # fmt subchunk
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes("fmt "))
    $writer.Write([int]16) # Subchunk1Size
    $writer.Write([short]1) # AudioFormat (PCM)
    $writer.Write([short]1) # NumChannels (Mono)
    $writer.Write([int]$SampleRate)
    $writer.Write([int]$byteRate)
    $writer.Write([short]2) # BlockAlign
    $writer.Write([short]16) # BitsPerSample

    # data subchunk
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes("data"))
    $writer.Write([int]$subChunk2Size)

    foreach ($s in $samples) {
        $clamped = [math]::Max(-32767, [math]::Min(32767, [int]$s))
        $writer.Write([short]$clamped)
    }

    $writer.Close()
    $stream.Close()
    Write-Output "Generated WAV: $Path ($numSamples samples)"
}

# Footstep SFX (0.08s pleasant soft thud)
Write-WavFile -Path (Join-Path $audioDir "sfx_footstep.wav") -GenerateSamples {
    param($sr)
    $dur = 0.08
    $total = [int]($sr * $dur)
    $out = [System.Collections.Generic.List[short]]::new($total)
    for ($i=0; $i -lt $total; $i++) {
        $t = $i / $sr
        $env = [math]::Exp(-$t * 45.0)
        $noise = ((($i * 7919) % 2000) - 1000) / 1000.0
        $freq = 110.0 - ($t * 400.0)
        $wave = [math]::Sin(2.0 * [math]::PI * $freq * $t) * 0.7 + $noise * 0.3
        $sample = [short]($wave * $env * 16000)
        $out.Add($sample)
    }
    return $out
}

# Dialog Blip SFX (0.04s soft typewriter blip)
Write-WavFile -Path (Join-Path $audioDir "sfx_dialog.wav") -GenerateSamples {
    param($sr)
    $dur = 0.04
    $total = [int]($sr * $dur)
    $out = [System.Collections.Generic.List[short]]::new($total)
    for ($i=0; $i -lt $total; $i++) {
        $t = $i / $sr
        $env = [math]::Exp(-$t * 70.0)
        $wave = [math]::Sin(2.0 * [math]::PI * 520.0 * $t)
        $sample = [short]($wave * $env * 14000)
        $out.Add($sample)
    }
    return $out
}

# Collect Item SFX (0.35s 2-tone uplifting chime: C6 -> G6)
Write-WavFile -Path (Join-Path $audioDir "sfx_collect.wav") -GenerateSamples {
    param($sr)
    $dur = 0.35
    $total = [int]($sr * $dur)
    $out = [System.Collections.Generic.List[short]]::new($total)
    for ($i=0; $i -lt $total; $i++) {
        $t = $i / $sr
        $freq = if ($t -lt 0.12) { 1046.5 } else { 1567.98 } # C6 -> G6
        $env = [math]::Exp(-($t % 0.12) * 18.0)
        $wave = [math]::Sin(2.0 * [math]::PI * $freq * $t) + 0.3 * [math]::Sin(4.0 * [math]::PI * $freq * $t)
        $sample = [short]($wave * $env * 18000)
        $out.Add($sample)
    }
    return $out
}

# Gate Unlock SFX (0.7s magical chime & deep hum)
Write-WavFile -Path (Join-Path $audioDir "sfx_gate_unlock.wav") -GenerateSamples {
    param($sr)
    $dur = 0.7
    $total = [int]($sr * $dur)
    $out = [System.Collections.Generic.List[short]]::new($total)
    for ($i=0; $i -lt $total; $i++) {
        $t = $i / $sr
        $env = [math]::Exp(-$t * 4.0)
        $hum = [math]::Sin(2.0 * [math]::PI * 130.0 * $t) * 0.6
        $sparkle = [math]::Sin(2.0 * [math]::PI * (440.0 + $t * 800.0) * $t) * 0.4
        $sample = [short](($hum + $sparkle) * $env * 20000)
        $out.Add($sample)
    }
    return $out
}

# Escape Fanfare SFX (1.5s victory arpeggio: C5 -> E5 -> G5 -> C6 sustained)
Write-WavFile -Path (Join-Path $audioDir "sfx_escape.wav") -GenerateSamples {
    param($sr)
    $dur = 1.5
    $total = [int]($sr * $dur)
    $out = [System.Collections.Generic.List[short]]::new($total)
    $notes = @(
        @{ t0=0.0;  t1=0.2;  f=523.25 }, # C5
        @{ t0=0.2;  t1=0.4;  f=659.25 }, # E5
        @{ t0=0.4;  t1=0.65; f=783.99 }, # G5
        @{ t0=0.65; t1=1.5;  f=1046.5 }  # C6 (Long)
    )
    for ($i=0; $i -lt $total; $i++) {
        $t = $i / $sr
        $currentNote = $notes | Where-Object { $t -ge $_.t0 -and $t -lt $_.t1 } | Select-Object -First 1
        if ($currentNote) {
            $localT = $t - $currentNote.t0
            $decay = if ($currentNote.f -eq 1046.5) { 2.0 } else { 8.0 }
            $env = [math]::Exp(-$localT * $decay)
            $wave = [math]::Sin(2.0 * [math]::PI * $currentNote.f * $t) + 0.35 * [math]::Sin(4.0 * [math]::PI * $currentNote.f * $t)
            $sample = [short]($wave * $env * 22000)
            $out.Add($sample)
        } else {
            $out.Add([short]0)
        }
    }
    return $out
}

# Ambient Background Music (8s looping soothing melody)
Write-WavFile -Path (Join-Path $audioDir "bgm_calm.wav") -GenerateSamples {
    param($sr)
    $dur = 8.0
    $total = [int]($sr * $dur)
    $out = [System.Collections.Generic.List[short]]::new($total)
    $melody = @(
        @{ t0=0.0; t1=1.0; f=261.63 }, # C4
        @{ t0=1.0; t1=2.0; f=329.63 }, # E4
        @{ t0=2.0; t1=3.0; f=392.00 }, # G4
        @{ t0=3.0; t1=4.0; f=329.63 }, # E4
        @{ t0=4.0; t1=5.0; f=293.66 }, # D4
        @{ t0=5.0; t1=6.0; f=349.23 }, # F4
        @{ t0=6.0; t1=7.0; f=392.00 }, # G4
        @{ t0=7.0; t1=8.0; f=261.63 }  # C4
    )
    for ($i=0; $i -lt $total; $i++) {
        $t = $i / $sr
        $currentNote = $melody | Where-Object { $t -ge $_.t0 -and $t -lt $_.t1 } | Select-Object -First 1
        $localT = $t - $currentNote.t0
        $env = (1.0 - [math]::Exp(-$localT * 10.0)) * [math]::Exp(-$localT * 1.5)
        $wave = [math]::Sin(2.0 * [math]::PI * $currentNote.f * $t) + 0.25 * [math]::Sin(4.0 * [math]::PI * $currentNote.f * $t)
        # Low warm pad chord in background
        $pad = [math]::Sin(2.0 * [math]::PI * 130.81 * $t) * 0.2 + [math]::Sin(2.0 * [math]::PI * 196.0 * $t) * 0.15
        $sample = [short](($wave * $env * 0.7 + $pad * 0.3) * 12000)
        $out.Add($sample)
    }
    return $out
}

Write-Output "ALL ASSETS GENERATED SUCCESSFULLY!"
