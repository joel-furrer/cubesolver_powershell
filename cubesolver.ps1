#cubesolver.ps1

# ---------- creating the cube ----------

#create class RubiksCube
class RubiksCube {
  [string[][]]$Top
  [string[][]]$Right
  [string[][]]$Back
  [string[][]]$Left
  [string[][]]$Bottom
  [string[][]]$Front

  # all values are read from Top to bottom, left to right
  # the top side starts as viewed so that the back side is "over" the top
  # the bottom starts as views so that the front side is "over" the bottom

  RubiksCube() {
    $this.Top     =   @(@("-", "-", "-"), @("-", "-", "-" ), @("-", "-", "-"))
    $this.Right   =   @(@("-", "-", "-"), @("-", "-", "-" ), @("-", "-", "-"))
    $this.Back    =   @(@("-", "-", "-"), @("-", "-", "-" ), @("-", "-", "-"))
    $this.Left    =   @(@("-", "-", "-"), @("-", "-", "-" ), @("-", "-", "-"))
    $this.Bottom  =   @(@("-", "-", "-"), @("-", "-", "-" ), @("-", "-", "-"))
    $this.Front   =   @(@("-", "-", "-"), @("-", "-", "-" ), @("-", "-", "-"))

  }
  



# ---------------------------------- let user write in the colors --------------------------------------------



    
  # ----- iterate through sides, rows, and then columns
  
  [void] WriteCube() {
    # create array of the sides, to iterate
    $sides = @("Top", "Right", "Back", "Left", "Bottom", "Front")
    $sideColors = @("Yellow", "Blue", "Red", "Green", "White", "Orange")
    $validColors = @("Y", "B", "R", "G", "W", "O")
    $middlepiece = 0
    
    foreach ($side in $sides) {
        $color = $sideColors[$middlepiece]
        Write-Host "Filling side: $side, Where the middlepiece is: $color"
        $middlepiece++
        $rowNumber = 0
        for ($row = 0; $row -lt 3; $row++) {
            $rowNumber = $row + 1
            Write-Host "You are on row: $rowNumber"
            
            for ($column = 0; $column -lt 3; $column++) {
                $input = ""
                $isValid = $false
                
                while (-not $isValid) {
                    $input = Read-Host "Enter a color: "
                    $input = $input.ToUpper()
                    
                    if ($validColors -contains $input) {
                        $this."$side"[$row][$column] = $input
                        $isValid = $true
                    } else {
                        Write-Host "Invalid input. Please enter a valid color code (Y, B, R, G, W, O)."
                    }
                }
            }
        }
        Write-Host "$side Side written.`n"
    }
  }
  
  # ----- print cube content
  [void]PrintCube() {
        $sides = @("Top", "Right", "Back", "Left", "Bottom", "Front")
        $sideColors = @("Yellow", "Blue", "Red", "Green", "White", "DarkYellow")
        $sideColorNames = @("Yellow", "Blue", "Red", "Green", "White", "Orange")
        $sideNames = @($this.Top, $this.Right, $this.Back, $this.Left, $this.Bottom, $this.Front)

        for ($sideIndex = 0; $sideIndex -lt $sides.Count; $sideIndex++) {
            $sideName = $sides[$sideIndex]
            $sideColor = $sideColorNames[$sideIndex]
            $currentSide = $sideNames[$sideIndex]

            Write-Host "[---------------------------------------------------------------]"
            Write-Host "|  Printing side: [ $sideName ] where the middlepiece is: [ $sideColor ]"
            Write-Host "[---------------------------------------------------------------]"

            foreach ($row in $currentSide) {
                foreach ($tile in $row) {
                    $tileColor = switch ($tile) {
                        "Y" { "Yellow" }
                        "B" { "Blue" }
                        "R" { "Red" }
                        "G" { "Green" }
                        "W" { "White" }
                        "O" { "DarkYellow" }
                        default { "Gray" }
                    }
                    Write-Host $tile -NoNewline -ForegroundColor $tileColor
                    Write-Host " " -NoNewline
                }
                Write-Host "" # Neue Zeile nach jeder Reihe
            }
            Write-Host "" # Leerzeile zwischen den Seiten
        }
  }

  
  # ----- check if the cube is correct
  [bool] CheckCube() {
    $executor = "[CUBE-CHECKER]:"
    # Check if the middle pieces appear at the correct place
    # Hashtable with key-value pairs of the side and the middle pieces
    $middlePieces = @{
        "Top"    = "Y"
        "Bottom" = "W"
        "Front"  = "O"
        "Back"   = "R"
        "Left"   = "G"
        "Right"  = "B"
    }
    
    foreach ($side in $middlePieces.Keys) {
        $expectedColor = $middlePieces[$side]
        $actualColor = $this."$side"[1][1]
        if ($actualColor -ne $expectedColor) {
            Write-Host "$executor Middle piece on $side is incorrect: Expected $expectedColor but got $actualColor."
            return $false
        } else {
              Write-Host "$executor Middle piece on $side is correct: $actualColor"
              
        }
    }
    
    # Check if all colors appear 9 times
    $colorCounts = @{}
    $sides = @("Top", "Right", "Back", "Left", "Bottom", "Front")

    foreach ($side in $sides) {
        foreach ($row in $this."$side") {
            foreach ($color in $row) {
                if (-not $colorCounts.ContainsKey($color)) {
                    $colorCounts[$color] = 0
                }
                $colorCounts[$color]++
            }
        }
    }

    foreach ($color in $colorCounts.Keys) {
        if ($colorCounts[$color] -ne 9) {
            Write-Host ("$executor Color " + $color + " doesnt appear 9 times: Found " + $colorCounts[$color] + " times.")
            return $false
            } else {
              Write-Host ("$executor Color "+ $color + " appears 9 times.") 
        }
    }
  
    # check if all 12 required edge pieces are found
    # array of all edge pieces sorted alphabetically
    $edgePieces = @("BO", "BR", "BW", "BY", "GO", "GR", "GW", "GY", "OW", "OY", "RW", "RY")
    # empty hashtable to keep track of the found edgePieces
    $foundEdgePieces = @{}
    
    # location of all edge pieces
    $edgeLocations = @(
        @("Top", 0, 1, "Back", 0, 1),
        @("Top", 1, 0, "Left", 0, 1),
        @("Top", 1, 2, "Right", 0, 1),
        @("Top", 2, 1, "Front", 0, 1),
        
        @("Bottom", 0, 1, "Front", 2, 1),
        @("Bottom", 1, 0, "Left", 2, 1),
        @("Bottom", 1, 2, "Right", 2, 1),
        @("Bottom", 2, 1, "Back", 2, 1),
        
        @("Front", 1, 0, "Left", 1, 2),
        @("Front", 1, 2, "Right", 1, 0),
        
        @("Back", 1, 0, "Right", 1, 2),
        @("Back", 1, 2, "Left", 1, 0)
    )
    
    # iterate through the given locations of th edge pieces 
    foreach ($edgepiece in $edgeLocations) {
        # vars showing which value in the elements of "$edgeLocations" to look for
        $side1   = $edgepiece[0]
        $row1    = $edgepiece[1]
        $column1 = $edgepiece[2]
        $side2   = $edgepiece[3]
        $row2    = $edgepiece[4]
        $column2 = $edgepiece[5]
        
        # store the found color 
        $color1 = $this."$side1"[$row1][$column1]
        $color2 = $this."$side2"[$row2][$column2]
        
        # sort the found colors by alphabet and join them
        $edgePieceColors = ($color1, $color2 | Sort-Object) -join ""
        
        # count the number of found edgePieces, and add them
        if (-not $foundEdgePieces.ContainsKey($edgePieceColors)) {
            $foundEdgePieces[$edgePieceColors] = 1
        }
        $foundEdgePieces[$edgePieceColors]
    }
    
    # check if every piece appears exactly once
    $allEdgePiecesPresent = $true
    
    foreach ($requiredEdge in $edgePieces) {
      if ($foundEdgePieces.ContainsKey($requiredEdge) -and $foundEdgePieces[$requiredEdge] -eq 1) {
        Write-Host "$executor Edge piece $requiredEdge found exactly once."    
      } else {
          Write-Host "$executor Edge piece $requiredEdge is either missing or appears to often."
          $allEdgePiecesPresend = $false
          return $false
      }
    }
    
    if ($allEdgePiecesPresent) {
        Write-Host "$executor All 12 edge pieces found."
    } else {
        Write-Host "$executor An Error occured while trying to find all edge pieces."
        return $false
    }
    
    # check if all 8 corner pieces are present
    $cornerPieces = @("BOW", "BOY", "BRW", "BRY", "GOW", "GOY", "GRW", "GRY")
    $foundCornerPieces = @{}

    # Define the locations of all corner pieces
    $cornerLocations = @(
        @("Right",2,0,"Front",2,2,"Bottom",0,2),    # BOW
        @("Right",0,0,"Front",0,2,"Top",2,2),     # BOY
        @("Right",2,2,"Back",2,0,"Bottom",2,2),   # BRW
        @("Right",0,2,"Back",0,0,"Top",0,2),    # BRY
        @("Left",2,2,"Front",2,0,"Bottom",0,0), # GOW
        @("Left",0,2,"Front",0,0,"Top",2,0),# GOY
        @("Left",2,0,"Back",2,2,"Bottom",2,0),  # GRW
        @("Left",0,0,"Back",0,2,"Top",0,0)  # GRY
    )

    # Count each corner piece found in the cube
    foreach ($corner in $cornerLocations) {
        $side1   = $corner[0]
        $row1    = $corner[1]
        $col1    = $corner[2]
        $side2   = $corner[3]
        $row2    = $corner[4]
        $col2    = $corner[5]
        $side3   = $corner[6]
        $row3    = $corner[7]
        $col3    = $corner[8]
    
        # Get colors at the corner positions
        $color1 = $this."$side1"[$row1][$col1]
        $color2 = $this."$side2"[$row2][$col2]
        $color3 = $this."$side3"[$row3][$col3]
    
        # Sort colors alphabetically to form the corner piece identifier
        $cornerPieceColors = ($color1, $color2, $color3 | Sort-Object) -join ""
    
        # Increment the count for this corner piece in the hashtable
        if (-not $foundCornerPieces.ContainsKey($cornerPieceColors)) {
           $foundCornerPieces[$cornerPieceColors] = 1
        } else {
           $foundCornerPieces[$cornerPieceColors]++
        }
    }

    # Check if each required corner piece appears exactly once
    $allCornerPiecesPresent = $true

    foreach ($requiredCorner in $cornerPieces) {
        if ($foundCornerPieces.ContainsKey($requiredCorner) -and $foundCornerPieces[$requiredCorner] -eq 1) {
            Write-Host "$executor Corner piece $requiredCorner found exactly once."
        } else {
            Write-Host "$executor Corner piece $requiredCorner is either missing or appears too often."
            $allCornerPiecesPresent = $false
            return $false
        }
    }

    # Summary message
    if ($allCornerPiecesPresent) {
        Write-Host "$executor All 8 corner pieces found."
    } else {
    Write-Host "$executor An error occurred while trying to find all corner pieces."
    }
    
    return $true
  
  }
  
  [string] StageFinder () {
    $executor = "[STAGE-FINDER]:"
    # coordinates of the cross
    $crossShape = @(
        (0, 1),
        (1, 0),
        (1, 1),
        (1, 2),
        (2, 1)
    )
    
    $crossFound = $true
      
    foreach ($coordinate in $crossShape ) {
        $row    = $coordinate[0]
        $column = $coordinate[1]
        
        if ($this.Bottom[$row][$column] -ne "W") {
            $crossFound = $false
            break
        }
    }

    if ($crossFound) {
        Write-Host "$executor Stage (1) > Cross found"
    } else {
        Write-Host "$executor The cube is ready for the first step."
        return "CROSS"
    }
    
    $f2lFound = $true
    
    $f2lSides = @("Right", "Back", "Left", "Front")
    
    $f2lExpectedColors = @("B", "R", "G", "O")
    
    $f2lCounter = 0
    foreach ($side in $f2lSides) {
        for ($column = 1; $column -le 2; $column++) {
            for ($row = 0; $row -le 2; $row++) {
                $f2lColorFound = $this."$side"[$column][$row]
                $f2lColorWanted = $f2lExpectedColors[$f2lCounter]
                
                if ($f2lColorFound -ne $f2lColorWanted) {
                    $f2lFound = $false
                    break
                }
            }
        }
        $f2lCounter++
    }
    
    #check if the bottom side is all-white
    
    for ($column = 0; $column -le 2; $column++ ) {
        for ($row = 0; $row -le 2; $row++ ) {
            $f2lBottomColorFound = $this.Bottom[$column][$row]
            $f2lBottomColorWanted = "W"
            if ($f2lBottomColorFound -ne $f2lBottomColorWanted ) {
                $f2lFound = $false
                break
                
            }
        }
          
    }
    
    if ($f2lFound) {
        Write-Host "$executor Stage (2) > First Two Layers found"
    } else {
        Write-Host "$executor The cube is ready for the second step."
        return "F2L"
    }

    # check if top layer is oriented
    
    $ollFound = $true
    
    for ($column = 0; $column -le 2; $column++ ) {
        for ($row = 0; $row -le 2; $row++ ) {
            $ollColorFound = $this.Top[$column][$row]
            $ollColorWanted = "Y"
            if ($ollColorFound -ne $ollColorWanted ) {
                $ollFound = $false
                break       
            }
        }
    }
    
    if ($ollFound) {
        Write-Host "$executor Stage (3) > Last Layer Oriented"
    } else {
        Write-Host "$executor The cube is ready for the third step."
        return "OLL"
    }
    
    # check if cube is solved
    $pllSideColors = @{
        "Top"    = "Y"
        "Bottom" = "W"
        "Front"  = "O"
        "Back"   = "R"
        "Left"   = "G"
        "Right"  = "B"
    }
    
    $pllFound = $true
    
    foreach ($side in $pllSideColors.Keys) {
        for ($column = 0; $column -le 2; $column++) {
            for ($row = 0; $row -le 2; $row++ ) {
                $pllColorFound = $this."$side"[$column][$row]
                $pllColorWanted = $pllSideColors[$side]
                if ($pllColorFound -ne $pllColorWanted) {
                    $pllFound = $false
                    break
                }
            }
        }
    }
    
    if ($pllFound) {
        Write-Host "$executor Stage (4) > Last Layer Permuted"
        return "SOLVED"
    } else {
        Write-Host "$executor The cube is ready for the last step."
        return "PLL"
    }
        
    
  } # stageFinder
  
  # ------------------------------ methods for moving the  tiles ----------------------------------------- 
  
  # spin a 3x3 field/side clockwise
  [void] doMoveSpinCW($move) {
    $executor = "[CUBE-SPINNER]"
    $expectedColorForMove = @{
        "U" = "Y"
        "L" = "G"
        "F" = "O"
        "R" = "B"
        "B" = "R"
        "D" = "W"
    }

    $sidesForMoves = @{
        "U" = "Top"
        "L" = "Left"
        "F" = "Front"
        "R" = "Right"
        "B" = "Back"
        "D" = "Bottom"
    }

    $selectedSide = $sidesForMoves[$move]

    $tempSide = @(
        @("-", "-", "-"),
        @("-", "-", "-"),
        @("-", "-", "-")
    )

    # Copy values from the side to tempSide
    for ($row = 0; $row -le 2; $row++) {
        for ($column = 0; $column -le 2; $column++) {
            $tempSide[$row][$column] = $this."$selectedSide"[$row][$column]
        }
    }

    # Check middle piece
    $validMiddlepiece = $expectedColorForMove[$move]
    $foundMiddlepiece = $tempSide[1][1]

    $ringShape = @((0,0), (0,1), (0,2), (1,2), (2,2), (2,1), (2,0), (1,0))
    $ringShapeRotated = @((0,2), (1,2), (2,2), (2,1), (2,0), (1,0), (0,0), (0,1))

    # Rotate the side by assigning colors to new positions
    for ($selectedRingTile = 0; $selectedRingTile -lt $ringShape.Count; $selectedRingTile++) {
        $sourceRow = $ringShape[$selectedRingTile][0]
        $sourceColumn = $ringShape[$selectedRingTile][1]
        $destRow = $ringShapeRotated[$selectedRingTile][0]
        $destColumn = $ringShapeRotated[$selectedRingTile][1]

        # Move color to the new rotated position
        $this."$selectedSide"[$destRow][$destColumn] = $tempSide[$sourceRow][$sourceColumn]
    }

    Write-Host "$executor $selectedSide side rotated clockwise."
    # Print the side after rotation
    for ($row = 0; $row -lt 3; $row++) {
        $rowContent = $this."$selectedSide"[$row] -join " "
        Write-Host $rowContent
    }
  }
  
  
  # rotate four 1x3 lines around the cube 
  [void] doMoveTurningCW($side, $orientation, $locationString, $rotation) {
      $executor = "[CUBE-MOVER]:"
      $location = [int]$locationString
      
      function SwapTileLocation {
          
          param (
              [string]$srcSide,
              [int]$srcRow,
              [int]$srcColumn,
              [string]$destSide,
              [int]$destRow,
              [int]$destColumn
          ) 
          
          if (-not $this."$srcSide" -or -not $this."$destSide") {
            Write-Host "$executor Error: $srcSide or $destSide not initialised." -ForegroundColor Red
            return
          }
          
          $tempTile = $this."$srcSide"[$srcRow][$srcColumn]
          $this."$srcSide"[$srcRow][$srcColumn] = $this."$destSide"[$destRow][$destColumn]
          $this."$destSide"[$destRow][$destColumn] = $tempTile
          
          Write-Host "$executor Swapped Tiles {$srcSide,$srcRow,$srcColumn} <-> {$destSide,$destRow,$destColumn}"
          
      }
      
      $possibleSideSteps = @(
          @("Top", "Back", "Bottom", "Front"),
          @("Top", "Right", "Bottom", "Left"),
          @("Front", "Right", "Back", "Left")
      )
      
      $invertLocation = 0 
      
      switch($location) {
          0 { $invertLocation = 2 }
          1 { $invertLocation = 1 }
          2 { $invertLocation = 0 }
      }
        
      
      Write-Host "$executor Selected orientation: $orientation"
      
      function TurnCW() {
            if ($orientation -eq "V") {
                SwapTileLocation "Top" 0 $location "Back" 2 $invertLocation    
                SwapTileLocation "Top" 1 $location "Back" 1 $invertLocation    
                SwapTileLocation "Top" 2 $location "Back" 0 $invertLocation
                
                SwapTileLocation "Top" 0 $location "Bottom" 0 $location 
                SwapTileLocation "Top" 1 $location "Bottom" 1 $location    
                SwapTileLocation "Top" 2 $location "Bottom" 2 $location    
                
                SwapTileLocation "Top" 0 $location "Front" 0 $location   
                SwapTileLocation "Top" 1 $location "Front" 1 $location  
                SwapTileLocation "Top" 2 $location "Front" 2 $location  
            } elseif ($orientation -eq "H" -and $side -eq "Top") {
                SwapTileLocation "Top" $location 0 "Right" 0 $invertLocation   
                SwapTileLocation "Top" $location 1 "Right" 1 $invertLocation  
                SwapTileLocation "Top" $location 2 "Right" 2 $invertLocation
                
                SwapTileLocation "Top" $location 0 "Bottom" $invertLocation 2   
                SwapTileLocation "Top" $location 1 "Bottom" $invertLocation 1  
                SwapTileLocation "Top" $location 2 "Bottom" $invertLocation 0
                
                SwapTileLocation "Top" $location 0 "Left" 2 $location   
                SwapTileLocation "Top" $location 1 "Left" 1 $location  
                SwapTileLocation "Top" $location 2 "Left" 0 $location
                
            } elseif ($orientation -eq "H" -and $side -eq "Front") {
                SwapTileLocation "Front" $location 0 "Right" $location 0
                SwapTileLocation "Front" $location 1 "Right" $location 1
                SwapTileLocation "Front" $location 2 "Right" $location 2
                
                SwapTileLocation "Front" $location 0 "Back" $location 0
                SwapTileLocation "Front" $location 1 "Back" $location 1
                SwapTileLocation "Front" $location 2 "Back" $location 2
                
                SwapTileLocation "Front" $location 0 "Left" $location 0
                SwapTileLocation "Front" $location 1 "Left" $location 1
                SwapTileLocation "Front" $location 2 "Left" $location 2
            }
                            
      }
      
      function TurnCCW() {
          for ($i = 0; $i -le 2; $i++) {
              TurnCW
          }
      }
      
      if ($rotation -eq "CW") {
          TurnCW
      } elseif ($rotation -eq "CCW") {
          TurnCCW
      } else {
          Write-Host "$executor An error occured: Invalid rotation"
      }
      
  }
  
  
  
  # ------ low-hierarchy methods for the notation ------
  
  [void] doMove($move, $rotation) {
      
      function doMoveCW($move) {
          switch($move) {
              "U" { $this.doMoveTurningCW("Front","H","0","CCW"); $this.doMoveSpinCW("U") }
              "L" { $this.doMoveTurningCW("Top","V","0","CCW");   $this.doMoveSpinCW("L") } 
              "F" { $this.doMoveTurningCW("Top","H","2","CW");    $this.doMoveSpinCW("F") } 
              "R" { $this.doMoveTurningCW("Top","V","2","CW");    $this.doMoveSpinCW("R") }
              "B" { $this.doMoveTurningCW("Top","H","0","CCW");   $this.doMoveSpinCW("B") }
              "D" { $this.doMoveTurningCW("Front","H","2","CW");  $this.doMoveSpinCW("D") }
              
              "M" { $this.doMoveTurningCW("Top","V","1","CCW")  }
              "E" { $this.doMoveTurningCW("Front","H","1","CW") }
              "S" { $this.doMoveTurningCW("Top","H","1","CW")   }              
          }
      }
      
      function doMoveCCW($move) {
          for ($i = 0; $i -le 2; $i++) {
              doMoveCW "$move"
          }
      }
      
      function doDoubleMoveCW($move) {
          switch($move) { 
              "U_D" { doMoveCW "U"; doMoveCCW "E" }
              "L_D" { doMoveCW "L"; doMoveCW "M"  } 
              "F_D" { doMoveCW "F"; doMoveCW "S"  } 
              "R_D" { doMoveCW "R"; doMoveCCW "M" }
              "B_D" { doMoveCW "B"; doMoveCCW "S" }
              "D_D" { doMoveCW "D"; doMoveCW "E"  }
          }
      }
      
      function doDoubleMoveCCW($move) {
          for ($i = 0; $i -le 2; $i++) {
              doDoubleMoveCW "$move"
          }
      }
      
      function doWholeMoveCW($move) {
          switch ($move) {
              "X" { doMoveCW "R"; doDoubleMoveCCW "L_D"  }
              "Y" { doMoveCW "U"; doDoubleMoveCCW "D_D" }
              "Z" { doMoveCW "F"; doDoubleMoveCCW "B_D" }
          } 
      }
      
      function doWholeMoveCCW($move) {
          for ($i = 0; $i -le 2; $i++) {
              doWholeMoveCW "$move"
          }
      }
      
      if ($rotation -eq "CW") {
          switch($move) {
              "U" { doMoveCW "$move" }
              "L" { doMoveCW "$move" }
              "F" { doMoveCW "$move" }
              "R" { doMoveCW "$move" }
              "B" { doMoveCW "$move" }
              "D" { doMoveCW "$move" }
        
              "M" { doMoveCW "$move" }
              "E" { doMoveCW "$move" }
              "S" { doMoveCW "$move" }
              
              "U_D" { doDoubleMoveCW "$move" }
              "L_D" { doDoubleMoveCW "$move" }
              "F_D" { doDoubleMoveCW "$move" }
              "R_D" { doDoubleMoveCW "$move" }
              "B_D" { doDoubleMoveCW "$move" }
              "D_D" { doDoubleMoveCW "$move" }
              
              "X" { doWholeMoveCW "$move" }
              "Y" { doWholeMoveCW "$move" }
              "Z" { doWholeMoveCW "$move" } 
              
          }
      } elseif ($rotation -eq "CCW") {
          switch($move) {
              "U" { doMoveCCW "$move" }
              "L" { doMoveCCW "$move" }
              "F" { doMoveCCW "$move" }
              "R" { doMoveCCW "$move" }
              "B" { doMoveCCW "$move" }
              "D" { doMoveCCW "$move" }
        
              "M" { doMoveCCW "$move" }
              "E" { doMoveCCW "$move" }
              "S" { doMoveCCW "$move" }
              
              "U_D" { doDoubleMoveCCW "$move" }
              "L_D" { doDoubleMoveCCW "$move" }
              "F_D" { doDoubleMoveCCW "$move" }
              "R_D" { doDoubleMoveCCW "$move" }
              "B_D" { doDoubleMoveCCW "$move" }
              "D_D" { doDoubleMoveCCW "$move" }
              
              "X" { doWholeMoveCCW "$move" }
              "Y" { doWholeMoveCCW "$move" }
              "Z" { doWholeMoveCCW "$move" }
          }
      } 
      
  
  }
  
  [void] Move($move) {
      switch($move) {
          "U" { $this.doMove("U","CW") }
          "L" { $this.doMove("L","CW") }
          "F" { $this.doMove("F","CW") }
          "R" { $this.doMove("R","CW") }
          "B" { $this.doMove("B","CW") }
          "D" { $this.doMove("D","CW") }
          "M" { $this.doMove("M","CW") }
          "E" { $this.doMove("E","CW") }
          "S" { $this.doMove("S","CW") }
          "UD" { $this.doMove("U_D","CW") }
          "LD" { $this.doMove("L_D","CW") }
          "FD" { $this.doMove("F_D","CW") }
          "RD" { $this.doMove("R_D","CW") }
          "BD" { $this.doMove("B_D","CW") }
          "DD" { $this.doMove("D_D","CW") }
          "X" { $this.doMove("X","CW") }
          "Y" { $this.doMove("Y","CW") }
          "Z" { $this.doMove("Z","CW") }
          
          "UC" { $this.doMove("U","CCW") }
          "LC" { $this.doMove("L","CCW") }
          "FC" { $this.doMove("F","CCW") }
          "RC" { $this.doMove("R","CCW") }
          "BC" { $this.doMove("B","CCW") }
          "DC" { $this.doMove("D","CCW") }
          "MC" { $this.doMove("M","CCW") }
          "EC" { $this.doMove("E","CCW") }
          "SC" { $this.doMove("S","CCW") }
          "UDC" { $this.doMove("U_D","CCW") }
          "LDC" { $this.doMove("L_D","CCW") }
          "FDC" { $this.doMove("F_D","CCW") }
          "RDC" { $this.doMove("R_D","CCW") }
          "BDC" { $this.doMove("B_D","CCW") }
          "DDC" { $this.doMove("D_D","CCW") }
          "XC" { $this.doMove("X","CCW") }
          "YC" { $this.doMove("Y","CCW") }
          "ZC" { $this.doMove("Z","CCW")}
      }
  }
  
  [void] fillSolved() {
      $this.Top     = @(@("Y", "Y", "Y"), @("Y", "Y", "Y"), @("Y", "Y", "Y"))
      $this.Right   = @(@("B", "B", "B"), @("B", "B", "B"), @("B", "B", "B"))
      $this.Back    = @(@("R", "R", "R"), @("R", "R", "R"), @("R", "R", "R"))
      $this.Left    = @(@("G", "G", "G"), @("G", "G", "G"), @("G", "G", "G"))
      $this.Bottom  = @(@("W", "W", "W"), @("W", "W", "W"), @("W", "W", "W"))
      $this.Front   = @(@("O", "O", "O"), @("O", "O", "O"), @("O", "O", "O"))
  }
  
  [void] fillDebug() {
      $this.Top     = @(@("Y", "Y", "Y"), @("Y", "Y", "Y"), @("Y", "Y", "Y"))
      $this.Right   = @(@("R", "R", "R"), @("B", "B", "B"), @("B", "B", "B"))
      $this.Back    = @(@("G", "G", "G"), @("R", "R", "R"), @("R", "R", "R"))
      $this.Left    = @(@("O", "O", "O"), @("G", "G", "G"), @("G", "G", "G"))
      $this.Bottom  = @(@("W", "W", "W"), @("W", "W", "W"), @("W", "W", "W"))
      $this.Front   = @(@("B", "B", "B"), @("O", "O", "O"), @("O", "O", "O"))
  }
  
  [void] rotateCube() {
      $executor = "[CUBE-ROTATOR]:"
      $yellowMiddlePieceFalse = $true
      $orangeMiddlePieceFalse = $true
      while ($yellowMiddlePieceFalse) {
          $yellowMiddlePiece = $this.Top[1][1]
          if ($yellowMiddlePiece -eq "Y") {
              $yellowMiddlePieceFalse = $false
              Write-Host "$executor Found the Yellow Middle piece on the Top"
          } else {
              Write-Host "$executor Could not find Yellow Middle piece on Top"
          }
          $possibleMiddlePieceLocations = @("Right","Back","Left","Front","Bottom")
          $correctSide = "-"
          foreach ($side in $possibleMiddlePieceLocations) {
              $foundColor = $this."$side"[1][1]
              if ($foundColor -eq "Y") {
                  $correctSide = $side
              }
          }
          switch ($correctSide) {
              "Right"  { $this.Move("ZC"); Write-Host "Test1" }
              "Back"   { $this.Move("XC"); Write-Host "Test2" }
              "Left"   { $this.Move("Z"); Write-Host "Test3"  }
              "Front"  { $this.Move("X"); Write-Host "Test4"  }
              "Bottom" { $this.Move("X"); $this.Move("X"); Write-Host "Test5" }
              default { Write-Host "Error 1" }
          }
          $yellowMiddlePieceFalse = $false
      }    
      while ($orangeMiddlePieceFalse) {
          $orangeMiddlePiece = $this.Front[1][1]
          if ($orangeMiddlePiece -eq "O") {
              $orangeMiddlePieceFalse = $false  
          }
          $possibleMiddlePieceLocations = @("Right", "Back", "Left")
          $correctSide = "-"
          foreach ($side in $possibleMiddlePieceLocations) {
              $foundColor = $this."$side"[1][1]
              if ($foundColor -eq "O") {
                  $correctSide = $side
              } 
          }
          switch ($correctSide) {
              "Right" { $this.Move("Y") }
              "Back"  { $this.Move("Y"); $this.Move("Y") }
              "Left"  { $this.Move("YC") }
              default { Write-Host "Error 2" }
          }
          $orangeMiddlePieceFalse = $false
      }
      
      Write-Host "$executor Cube rotated"
  }
  
  [void] scrambleCube() {
        $moves = @("U", "L", "F", "R", "B", "D", "UC", "LC", "FC", "RC", "BC", "DC")
        
        for ($i = 0; $i -lt 20; $i++) {
            $randomMove = $moves | Get-Random
            $this.Move($randomMove)
        }
    }
  
  [void] solveCross() {
      $executor = "[CROSS-SOLVER]:"
      $sides = @("Top","Right","Back","Left","Bottom")
      $whiteEdgePieces = @("WB", "WR", "WG", "WO")
      $foundWhiteEdgePieces = @{}
      
      $foundEdgeLocations = @(
          @("-", 0, 0, "-", 0, 0), # White/Blue
          @("-", 0, 0, "-", 0, 0), # White/Red
          @("-", 0, 0, "-", 0, 0), # White/Green
          @("-", 0, 0, "-", 0, 0)  # White/Orange
      )
      
      $correctEdgeLocations = @(
          @("Bottom", 1, 2, "Right", 2, 1), # White/Blue
          @("Bottom", 2, 1, "Back", 2, 1), # White/Red
          @("Bottom", 1, 0, "Left", 2, 1), # White/Green
          @("Bottom", 0, 1, "Front", 2, 1)  # White/Orange
      )
      
      function fillEdgeLocation($sideWhite, $rowWhite, $columnWhite, $side, $rowNeighbour, $columnNeighbour) {
          $neighbourColor = $this."$side"[$rowNeighbour][$columnNeighbour]
          $location = 0
          
          if ($neighbourColor -eq "B") {
              $location = 0
              Write-Host "$executor Edge piece W$neighbourColor found."    
          } elseif ($neighbourColor -eq "R") {
              $location = 1
              Write-Host "$executor Edge piece W$neighbourColor found."    
          } elseif ($neighbourColor -eq "G") {
              $location = 2
              Write-Host "$executor Edge piece W$neighbourColor found."    
          } elseif ($neighbourColor -eq "O") {
              $location = 3
              Write-Host "$executor Edge piece W$neighbourColor found."    
          } else {
              Write-Host "$executor Error"
          }
          $foundEdgeLocations[$location][0] = $sideWhite
          $foundEdgeLocations[$location][1] = $rowWhite
          $foundEdgeLocations[$location][2] = $columnWhite
          $foundEdgeLocations[$location][3] = $side
          $foundEdgeLocations[$location][4] = $rowNeighbour
          $foundEdgeLocations[$location][5] = $columnNeighbour
          
          
      }
      
      $edgeCoordinates = @((0,1),(1,0),(1,2),(2,1))

      function searchTop () {
          for ($i = 0; $i -le 3; $i ++) {
              $selectedRow = $edgeCoordinates[$i][0]
              $selectedColumn = $edgeCoordinates[$i][1]
              $selectedColor = $this.Top[$selectedRow][$selectedColumn]
              if ($selectedColor -eq "W") {
                  switch($i) {
                      0 { fillEdgeLocation "Top" "$selectedRow" $selectedColumn "Back" 0 1 }
                      1 { fillEdgeLocation "Top" "$selectedRow" $selectedColumn "Left" 0 1 }
                      2 { fillEdgeLocation "Top" "$selectedRow" $selectedColumn "Right" 0 1 }
                      3 { fillEdgeLocation "Top" "$selectedRow" $selectedColumn "Front" 0 1 }
                  }
              }
          }
      }
      function searchRight () {
          for ($i = 0; $i -le 3; $i ++) {
              $selectedRow = $edgeCoordinates[$i][0]
              $selectedColumn = $edgeCoordinates[$i][1]
              $selectedColor = $this.Right[$selectedRow][$selectedColumn]
              if ($selectedColor -eq "W") {
                  switch($i) {
                      0 { fillEdgeLocation "Right" "$selectedRow" $selectedColumn "Top" 1 2 }
                      1 { fillEdgeLocation "Right" "$selectedRow" $selectedColumn "Front" 1 2 }
                      2 { fillEdgeLocation "Right" "$selectedRow" $selectedColumn "Back" 1 0 }
                      3 { fillEdgeLocation "Right" "$selectedRow" $selectedColumn "Bottom" 1 2 }
                  }
              }
          }
      }
      function searchBack () {
          for ($i = 0; $i -le 3; $i ++) {
              $selectedRow = $edgeCoordinates[$i][0]
              $selectedColumn = $edgeCoordinates[$i][1]
              $selectedColor = $this.Back[$selectedRow][$selectedColumn]
              if ($selectedColor -eq "W") {
                  switch($i) {
                      0 { fillEdgeLocation "Back" "$selectedRow" $selectedColumn "Top" 0 1 }
                      1 { fillEdgeLocation "Back" "$selectedRow" $selectedColumn "Right" 1 2 }
                      2 { fillEdgeLocation "Back" "$selectedRow" $selectedColumn "Left" 1 0 }
                      3 { fillEdgeLocation "Back" "$selectedRow" $selectedColumn "Bottom" 2 1 }
                  }
              }
          }
      }
      function searchLeft () {
          for ($i = 0; $i -le 3; $i ++) {
              $selectedRow = $edgeCoordinates[$i][0]
              $selectedColumn = $edgeCoordinates[$i][1]
              $selectedColor = $this.Left[$selectedRow][$selectedColumn]
              if ($selectedColor -eq "W") {
                  switch($i) {
                      0 { fillEdgeLocation "Left" "$selectedRow" $selectedColumn "Top" 1 0 }
                      1 { fillEdgeLocation "Left" "$selectedRow" $selectedColumn "Back" 1 2 }
                      2 { fillEdgeLocation "Left" "$selectedRow" $selectedColumn "Front" 1 0 }
                      3 { fillEdgeLocation "Left" "$selectedRow" $selectedColumn "Bottom" 1 0 }
                  }
              }
          }
      }
      function searchBottom () {
          for ($i = 0; $i -le 3; $i ++) {
              $selectedRow = $edgeCoordinates[$i][0]
              $selectedColumn = $edgeCoordinates[$i][1]
              $selectedColor = $this.Bottom[$selectedRow][$selectedColumn]
              if ($selectedColor -eq "W") {
                  switch($i) {
                      0 { fillEdgeLocation "Bottom" "$selectedRow" $selectedColumn "Front" 2 1 }
                      1 { fillEdgeLocation "Bottom" "$selectedRow" $selectedColumn "Left" 2 1 }
                      2 { fillEdgeLocation "Bottom" "$selectedRow" $selectedColumn "Right" 2 1 }
                      3 { fillEdgeLocation "Bottom" "$selectedRow" $selectedColumn "Back" 2 1 }
                  }
              }
          }
      }
      function searchFront () {
          for ($i = 0; $i -le 3; $i ++) {
              $selectedRow = $edgeCoordinates[$i][0]
              $selectedColumn = $edgeCoordinates[$i][1]
              $selectedColor = $this.Front[$selectedRow][$selectedColumn]
              if ($selectedColor -eq "W") {
                  switch($i) {
                      0 { fillEdgeLocation "Front" "$selectedRow" $selectedColumn "Top" 2 1 }
                      1 { fillEdgeLocation "Front" "$selectedRow" $selectedColumn "Left" 1 2 }
                      2 { fillEdgeLocation "Front" "$selectedRow" $selectedColumn "Right" 1 0 }
                      3 { fillEdgeLocation "Front" "$selectedRow" $selectedColumn "Bottom" 0 1 }
                  }
              }
          }
      }
      
      $movesForLocationWB = @(
          @("Top",0,1,"U","R","R"),
          @("Top",1,0,"U","U","R","R"),
          @("Top",1,2,"R","R"),
          @("Top",2,1,"UC","R","R"),

          @("Right",0,1,"RC","F","D"), #-- 4
          @("Right",1,0,"F","D"),
          @("Right",1,2,"BC","DC"),
          @("Right",2,1,"R","F","D"), #-- 7

          @("Back",0,1,"BC","R"),
          @("Back",1,0,"R"),
          @("Back",1,2,"LC","D","D"),
          @("Back",2,1,"B","R"),

          @("Left",0,1,"UC","F","RC"),
          @("Left",1,0,"B","DC"),
          @("Left",1,2,"FC","D"),
          @("Left",2,1,"D","FC","RC"), #--

          @("Bottom",0,1,"D"),
          @("Bottom",1,0,"D","D"),
          @("Bottom",2,1,"DC"),
          
          @("Front",0,1,"F","RC"),
          @("Front",1,0,"L","D","D"),
          @("Front",1,2,"RC"),
          @("Front",2,1,"FC","RC") 
      )
      $movesForLocationWR = @(
          @("Top",0,1,"B","B"),
          @("Top",1,0,"U","B","B"),
          @("Top",1,2,"UC","B","B"),
          @("Top",2,1,"U","U","B","B"),

          @("Right",0,1,"R","BC","RC"),
          @("Right",1,0,"R","R","BC","RC","RC"), #--
          @("Right",1,2,"BC"),

          @("Back",0,1,"UC","LC","B"), #-- 
          @("Back",1,0,"R","D","RC"),
          @("Back",1,2,"LC","R","DC","RC"),
          @("Back",2,1,"B","R","D","RC"),

          @("Left",0,1,"LC","B"), #-- 11
          @("Left",1,0,"B"),
          @("Left",1,2,"L","L","B"),
          @("Left",2,1,"L","B"), #--

          @("Bottom",0,1,"R","D","D","RC"), #-- 
          @("Bottom",1,0,"R","DC","RC"),
          #@("Bottom",1,2,"")
          
          @("Front",0,1,"UC","R","BC","RC"),
          @("Front",1,0,"LC","U","B","B"), #-- 
          @("Front",1,2,"FC","U","LC","B"),
          @("Front",2,1,"F","LC","U","B","B") #-- F,LC,U,B,B
      )
      $movesForLocationWG = @(
          @("Top",0,1,"UC","L","L"),
          @("Top",1,0,"L","L"),
          @("Top",1,2,"U","U","L","L"),
          @("Top",2,1,"U","L","L"),

          @("Right",0,1,"RC","B","F","DC","BC","R"),
          @("Right",1,0,"FC","U","L","L"), 
          @("Right",1,2,"BC","R","D","B","RC"),

          @("Back",0,1,"B","LC","BC"),
          @("Back",1,0,"B","U","U","BC","FC","L"), #--
          @("Back",1,2,"LC"), #--
          @("Back",2,1,"B","L")

          @("Left",0,1,"UC","FC","L"), #--
          @("Left",1,0,"L","L","FC","BC","RC","DC","R","B"),
          @("Left",1,2,"FC","BC","RC","DC","R","B"),
          @("Left",2,1,"LC","F","U","L","L")

          @("Bottom",0,1,"BC","RC","DC","R","B"),
          @("Bottom",1,2,"R","F","F","L")
          
          @("Front",0,1,"FC","L"),
          @("Front",1,0,"L"),
          @("Front",1,2,"FC","FC","L"),
          @("Front",2,1,"F","L") 
      )
      $movesForLocationWO = @(
          @("Top",0,1,"U","U","F","F"),
          @("Top",1,0,"UC","F","F"),
          @("Top",1,2,"U","F","F"),
          @("Top",2,1,"F","F"),

          @("Right",0,1,"RC","FC","R","F","F"),
          @("Right",1,0,"F"),
          @("Right",1,2,"R","R","F","RC","RC"),
          @("Right",2,1,"R","BC")

          @("Back",0,1,"U","RC","F","R"),
          @("Back",1,0,"B","U","BC","RC","F","R"),
          @("Back",1,2,"BC","UC","B","L","FC","LC"),

          @("Left",0,1,"L","FC","LC"),
          @("Left",1,0,"L","L","FC","LC","LC"),
          @("Left",1,2,"FC"),
          
          @("Front",0,1,"F","R","U","RC","F","F"),
          @("Front",1,0,"F","F","R","U","RC","F","F"),
          @("Front",1,2,"R","U","RC","F","F"),
          @("Front",2,1,"F","F","U","L","FC","LC")
      )


      #$selectedMovesArray = $movesForLocationWB
      $foundEdgeLocationsIndex = 0

      function selectArray($color) {
          Write-Host "$executor Function selectArray called, using [$color]"
          $selectedMovesArray = $movesForLocationWB
          switch($color) {
              "B" { $selectedMovesArray = "movesForLocationWB"; $index = 0 }
              "R" { $selectedMovesArray = "movesForLocationWR"; $index = 1 }
              "G" { $selectedMovesArray = "movesForLocationWG"; $index = 2 }
              "O" { $selectedMovesArray = "movesForLocationWO"; $index = 3 }
              default { Write-Host "$executor Error" }
          }
          $foundEdgeLocationsIndex = $index
          return $selectedMovesArray
      }
      
      #$selectedSubArray = 0
      function selectSubArray($color) {
          Write-Host "$executor Function selectSubArray called, using [$color]" 
          switch ($color) {
              "B" { $selectedArray = $movesForLocationWB; $foundEdgeLocationsIndex = 0 }
              "R" { $selectedArray = $movesForLocationWR; $foundEdgeLocationsIndex = 1 }
              "G" { $selectedArray = $movesForLocationWG; $foundEdgeLocationsIndex = 2 }
              "O" { $selectedArray = $movesForLocationWO; $foundEdgeLocationsIndex = 3 }

          }
          
          $selectedSubArray = 0
          $arrayLength = $selectedArray.Length - 1
          Write-Host "$executor Array length is: $arrayLength"
          $arrayIsFound = $false
          for($i = 0; $i -le $arrayLength; $i++) {
              $checkedArray = $selectedArray[$i]
              Write-Host -NoNewline "`r$executor Checking Array: [ $i ] "
              $correctElements = 0
              for($index = 0; $index -le 2; $index++) {
                  $checkedArrayElement = $selectedArray[$i][$index]
                  $foundTile = $foundEdgeLocations[$foundEdgeLocationsIndex][$index]
                  $arrayIsFound = $false
                  $successCount = $index + 1 
                  if ($arrayIsFound -eq $false) {
                      if ($checkedArrayElement -eq $foundTile) {
                          $correctElements++
                      } else {
                          $correctElements = $correctElements - 1
                      }
                      if ($correctElements -eq 3) {
                          Write-Host "`n$executor Found Correct Array: $i!"
                          $arrayIsFound = $true
                      }
                  }
                  if ($arrayIsFound -eq $true) {
                      Write-Host "$executor (return $i)"
                      $returnValue = $i
                      return $returnValue
                  }
              }
          }
      }
      
      function applyMoves($selectedSubArray, $color) {
          Write-Host "$executor Function applyMoves called, using [$selectedSubArray], [$color]"
          Write-Host "$executor Selected Array: movesForLocationW$color, with subarray: $selectedSubArray"
          $arrayLength = 0
          $selArray = $movesForLocationWB
          switch ($color) {
              "B" { $selArray = $movesForLocationWB }
              "R" { $selArray = $movesForLocationWR }
              "G" { $selArray = $movesForLocationWG }
              "O" { $selArray = $movesForLocationWO }
          }
          $selSubArray = $selArray[$selectedSubArray]
          $selSubArrayLength = $selSubArray.Length - 1
          $arrayLength = $selArray.Length
          Write-Host "$executor Selected subarray number: $selectedSubArray"
          Write-Host "$executor Selected subarray has length: $selSubArrayLength"
          for ($i = 3; $i -le $selSubArrayLength; $i++) {
              $selectedMove = $selArray[$selectedSubArray][$i]
              Write-Host "$executor Executing Move: $selectedMove"
              $this.Move("$selectedMove")
          }
      
      }

      function solveWB () {
          $WB_NeedsChecking = $true
          if ($WB_NeedsChecking) {
              Write-Host "$executor Checking if the White-Blue piece is at the correct location..."
              $WB_IsUnsolved = $false
              for ($i = 0; $i -le 5; $i++) {
                  $elementCount = $i + 1
                  if ($foundEdgeLocations[0][$i] -eq $correctEdgeLocations[0][$i]) {
                      Write-Host "$executor Success: correct Location for Element ($elementCount/6)."
                  } else { 
                      Write-Host "$executor Fail: incorrect Location for Element ($elementCount/6)."
                      $debug = $foundEdgeLocations[0][$i]
                      $debug2 = $correctEdgeLocations[0][$i]

                      Write-Host "$executor ---> Found: $debug, Expected: $debug2"
                      $WB_IsUnsolved = $true
                  }
              }
          }
          if ($WB_IsUnsolved) {
              selectArray "B"
              $selectedSubArray = selectSubArray "B"
              Write-Host "$executor Selected subarray is: $selectedSubArray"
              ApplyMoves $selectedSubArray "B"
          } else {
              Write-Host "$executor The White-Blue Piece is already at the correct location."
          }
          
      }
      function solveWR () {
          $WR_NeedsChecking = $true
          if ($WR_NeedsChecking) {
              Write-Host "$executor Checking if the White-Red piece is at the correct location..."
              $WR_IsUnsolved = $false
              for ($i = 0; $i -le 5; $i++) {
                  $elementCount = $i + 1
                  if ($foundEdgeLocations[1][$i] -eq $correctEdgeLocations[1][$i]) {
                      Write-Host "$executor Success: correct Location for Element ($elementCount/6)."
                  } else { 
                      Write-Host "$executor Fail: incorrect Location for Element ($elementCount/6)." 
                      $debug = $foundEdgeLocations[1][$i]
                      $debug2 = $correctEdgeLocations[1][$i]

                      Write-Host "$executor ---> Found: $debug, Expected: $debug2"
                      $WR_IsUnsolved = $true
                  }
              }
          }
          if ($WR_IsUnsolved) {
              selectArray "R"
              $selectedSubArray = selectSubArray "R"
              Write-Host "$executor Selected subarray is: $selectedSubArray"
              ApplyMoves $selectedSubArray "R"
          } else {
              Write-Host "$executor The White-Red Piece is already at the correct location."
          }
          
      }
      function solveWG () {
          $WG_NeedsChecking = $true
          if ($WG_NeedsChecking) {
              Write-Host "$executor Checking if the White-Green piece is at the correct location..."
              $WG_IsUnsolved = $false
              for ($i = 0; $i -le 5; $i++) {
                  $elementCount = $i + 1
                  if ($foundEdgeLocations[2][$i] -eq $correctEdgeLocations[2][$i]) {
                      Write-Host "$executor Success: correct Location for Element ($elementCount/6)."
                  } else { 
                      Write-Host "$executor Fail: incorrect Location for Element ($elementCount/6)."
                      $debug = $foundEdgeLocations[2][$i]
                      $debug2 = $correctEdgeLocations[2][$i]

                      Write-Host "$executor ---> Found: $debug, Expected: $debug2"
                      $WG_IsUnsolved = $true
                  }
              }
          }
          if ($WG_IsUnsolved) {
              selectArray "G"
              $selectedSubArray = selectSubArray "G"
              Write-Host "$executor Selected subarray is: $selectedSubArray"
              ApplyMoves $selectedSubArray "G"
          } else {
              Write-Host "$executor The White-Green Piece is already at the correct location."
          }
          
      }
      function solveWO () {
          $WO_NeedsChecking = $true
          if ($WO_NeedsChecking) {
              Write-Host "$executor Checking if the White-Orange piece is at the correct location..."
              $WO_IsUnsolved = $false
              for ($i = 0; $i -le 5; $i++) {
                  $elementCount = $i + 1
                  if ($foundEdgeLocations[3][$i] -eq $correctEdgeLocations[3][$i]) {
                      Write-Host "$executor Success: correct Location for Element ($elementCount/6)."
                  } else { 
                      Write-Host "$executor Fail: incorrect Location for Element ($elementCount/6)."
                      $debug = $foundEdgeLocations[3][$i]
                      $debug2 = $correctEdgeLocations[3][$i]

                      Write-Host "$executor ---> Found: $debug, Expected: $debug2"
                      $WO_IsUnsolved = $true
                  }
              }
          }
          if ($WO_IsUnsolved) {
              selectArray "O"
              $selectedSubArray = selectSubArray "O"
              Write-Host "$executor Selected subarray is: $selectedSubArray"
              ApplyMoves $selectedSubArray "O"
          } else {
              Write-Host "$executor The White-Orange Piece is already at the correct location."
          }
          
      }

      function searchAll() {
          Write-Host "------------------------------------------------------------------------------------"
          Write-Host "$executor Searching [Top]"
          searchTop
          Write-Host "$executor Searching [Right]"
          searchRight
          Write-Host "$executor Searching [Back]"
          searchBack
          Write-Host "$executor Searching [Left]"
          searchLeft
          Write-Host "$executor Searching [Bottom]"
          searchBottom
          Write-Host "$executor Searching [Front]"
          searchFront
          $this.printCube()
      }
      
      
      $solveCrossDone = $false
      
      function solveCrossMain() {
          while($solveCrossDone -eq $false) {
              searchAll
              Write-Host "------------------------------------------"
              solveWB
              searchAll
              Write-Host "------------------------------------------"
              solveWR
              searchAll
              Write-Host "------------------------------------------"
              solveWG
              searchAll
              Write-Host "------------------------------------------"
              solveWO
              searchAll
              Write-Host "------------------------------------------"
              #----
              
              $solveCrossDone = $true #temp
              if ($foundEdgeLocations -eq $correctEdgeLocations) {
                  Write-Host "$executor Finished step (1) > Cross"
                  $solveCrossDone = $true
              }
          }
      }
      
      solveCrossMain
  }
  
  [void] SolveF2L() {
      $executor = "[F2L-SOLVER]:"
      
      
      # -> WBR, WRG, WGO, WOB
      $movesForCornerLocations = @(
          @("Top",0,0,"Left",0,0,"Back",0,2), #-- 0
          @("Top",0,2,"Back",0,0,"Right",0,2), #-- 1
          @("Top",2,0,"Front",0,0,"Left",0,2), #-- 2
          @("Top",2,2,"Right",0,0,"Front",0,2), #-- 3   

          @("Right",0,0,"Front",0,2,"Top",2,2), #-- 4
          @("Right",0,2,"Top",0,2,"Back",0,0), #-- 5
          @("Right",2,0,"Bottom",0,2,"Front",2,2), #-- 6
          @("Right",2,2,"Back",2,0,"Bottom",2,2), #-- 7          

          @("Back",0,0,"Right",0,2,"Top",0,2), #-- 8
          @("Back",0,2,"Top",0,0,"Left",0,0), #-- 9
          @("Back",2,0,"Bottom",2,2,"Right",2,2), #-- 1
          @("Back",2,2,"Left",2,0,"Bottom",2,0), #-- 11   

          @("Left",0,0,"Back",0,2,"Top",0,0), #--12
          @("Left",0,2,"Top",2,0,"Front",0,0), #--13 
          @("Left",2,0,"Bottom",2,0,"Back",2,2), #-- 14
          @("Left",2,2,"Front",2,0,"Bottom",0,0), #-- 15          

          @("Bottom",0,0,"Left",2,2,"Front",2,0), #-- 16
          @("Bottom",0,2,"Front",2,2,"Right",2,0), #-- 17
          @("Bottom",2,0,"Back",2,2,"Left",2,0), #-- 18
          @("Bottom",2,2,"Right",2,2,"Back",2,0), #-- 19         

          @("Front",0,0,"Left",0,2,"Top",2,0), #-- 20
          @("Front",0,2,"Top",2,2,"Right",0,0), #-- 21
          @("Front",2,0,"Bottom",0,0,"Left",2,2), #-- 22
          @("Front",2,2,"Right",2,0,"Bottom",0,2) #-- 23
      )
      
      $movesForEdgeLocations = @(
          @("Top",0,1,"Back",0,1),
          @("Top",1,0,"Left",0,1),
          @("Top",1,2,"Right",0,1),
          @("Top",0,1,"Front",0,1),
          
          @("Right",0,1,"Top",1,2),
          @("Right",1,0,"Front",1,2),
          @("Right",1,2,"Back",1,0),
          
          @("Back",0,1,"Top",0,1),
          @("Back",1,0,"Right",1,2),
          @("Back",1,2,"Left",1,0),
          
          @("Left",0,1,"Top",1,0),
          @("Left",1,0,"Back",1,2),
          @("Left",1,2,"Front",1,0),
          
          @("Front",0,1,"Top",2,1),
          @("Front",1,0,"Left",1,2),
          @("Front",1,2,"Right",1,0)
      )
      
      
      $cornerCoordinates = @((0,0),(0,2),(2,0),(2,2))
      
      $foundCornerLocations = @(
          @("-",0,0,"-",0,0,"-",0,0), #WBR
          @("-",0,0,"-",0,0,"-",0,0), #WRG
          @("-",0,0,"-",0,0,"-",0,0), #WGO
          @("-",0,0,"-",0,0,"-",0,0)  #WOB
      )
      
      function searchCornerPiecesCW($cornerColors) {
          for ($i = 0; $i -le 23; $i++) {
              Write-Host -NoNewline "`r$executor Checking Array: [ $i ]"
              $checkedElementSide1 = $movesForCornerLocations[$i][0]
              $checkedElementRow1 = $movesForCornerLocations[$i][1]
              $checkedElementColumn1 = $movesForCornerLocations[$i][2]
              $checkedCornerTile1 = $this."$checkedElementSide1"[$checkedElementRow1][$checkedElementColumn1]
              if ($checkedCornerTile1 -eq "W") {
                  Write-Host "`n$executor Found [ W ] at Array: [ $i ]"
                  $checkedElementSide2 = $movesForCornerLocations[$i][3]
                  $checkedElementRow2 = $movesForCornerLocations[$i][4]
                  $checkedElementColumn2 = $movesForCornerLocations[$i][5]
                  $checkedCornerTile2 = $this."$checkedElementSide2"[$checkedElementRow2][$checkedElementColumn2]
                  switch ($checkedCornerTile2) {
                      "B" { $element2 = "B"; Write-Host "$executor Found [ B ] at Array: [ $i ]" }
                      "R" { $element2 = "R"; Write-Host "$executor Found [ R ] at Array: [ $i ]" }
                      "G" { $element2 = "G"; Write-Host "$executor Found [ G ] at Array: [ $i ]" }
                      "O" { $element2 = "O"; Write-Host "$executor Found [ O ] at Array: [ $i ]" }
                      default { Write-Host "$executor An Error occured while trying to read a White Corner Piece." }
                  }
                  $checkedElementSide3 = $movesForCornerLocations[$i][6]
                  $checkedElementRow3 = $movesForCornerLocations[$i][7]
                  $checkedElementColumn3 = $movesForCornerLocations[$i][8]
                  $checkedCornerTile3 = $this."$checkedElementSide3"[$checkedElementRow3][$checkedElementColumn3]
                  switch ($checkedCornerTile3) {
                      "R" { $element3 = "R"; Write-Host "$executor Found [ R ] at Array: [ $i ]" }
                      "G" { $element3 = "G"; Write-Host "$executor Found [ G ] at Array: [ $i ]"}
                      "O" { $element3 = "O"; Write-host "$executor Found [ O ] at Array: [ $i ]"}
                      "B" { $element3 = "B"; Write-Host "$executor Found [ B ] at Array: [ $i ]"}
                      default { Write-Host "$executor An Error occured while trying to read a White Corner Piece." }
                  }
                  switch ($element2) {
                      "B" { $index = 0 }
                      "R" { $index = 1 }
                      "G" { $index = 2 }
                      "O" { $index = 3 }
                      default { Write-Host "$executor An Error occured while trying to read a White Corner Piece." }
                  }
                  # test if color combination is allowed                  
                  $colorCombinationIsAllowed = $false
                  if ( $element2 -eq "B" -and $element3 -eq "R") {
                      Write-Host "$executor Found Corner Piece: [ WBR ]"
                      $colorCombinationIsAllowed = $true
                  } elseif ( $element2 -eq "R" -and $element3 -eq "G") {
                      Write-Host "$executor Found Corner Piece: [ WRG ]"
                      $colorCombinationIsAllowed = $true
                  } elseif ( $element2 -eq "G" -and $element3 -eq "O") {
                      Write-Host "$executor Found Corner Piece: [ WGO ]"
                      $colorCombinationIsAllowed = $true
                  } elseif ( $element2 -eq "O" -and $element3 -eq "B") {
                      Write-Host "$executor Found Corner Piece: [ WOB ]"
                      $colorCombinationIsAllowed = $true
                  } else {
                      Write-Host "$executor Found Correct Colors, but in the Wrong Orientation"
                  }
                  if ($colorCombinationIsAllowed) {
                      for ($j = 0; $j -le 8; $j++) {
                          $foundCornerLocations[$index][$j] = $movesForCornerLocations[$i][$j]
                      }
                  }
              } else {
                  Write-Host
              }
          }
      }
      
      $movesForCornerLocationWBR = @(
          @("Top",0,0,"Left",0,0,"Back",0,2,"BC","U","B","B","UC","BC"),
          @("Top",0,2,"Back",0,0,"Right",0,2,"UC"),
          @("Top",2,0,"Front",0,0,"Left",0,2,"U"),
          @("Top",2,2,"Right",0,0,"Front",0,2,"U","U"),

          @("Right",0,0,"Front",0,2,"Top",2,2,"U","U"),
          @("Right",0,2,"Top",0,2,"Back",0,0,"U"),
          @("Right",2,0,"Bottom",0,2,"Front",2,2,"R","U","RC"),
          @("Right",2,2,"Back",2,0,"Bottom",2,2,"RC","UC","R"),

          @("Back",0,0,"Right",0,2,"Top",0,2,"UC"),
          @("Back",0,2,"Top",0,0,"Left",0,0,"U","U"),
          @("Back",2,0,"Bottom",2,2,"Right",2,2,"B","U","BC"),
          @("Back",2,2,"Left",2,0,"Bottom",2,0,"BC","UC","B"),

          @("Left",0,0,"Back",0,2,"Top",0,0,"RC","U","R"),
          @("Left",0,2,"Top",2,0,"Front",0,0,"UC"),
          @("Left",2,0,"Bottom",2,0,"Back",2,2,"L","U","LC"),
          @("Left",2,2,"Front",2,0,"Bottom",0,0,"LC","UC","L"),

          @("Bottom",0,0,"Left",2,2,"Front",2,0,"LC","U","L"),
          @("Bottom",0,2,"Front",2,2,"Right",2,0,"FC","UC","F"), #fixed
          @("Bottom",2,0,"Back",2,2,"Left",2,0,"BC","UC","B"),
          @("Bottom",2,2,"Right",2,2,"Back",2,0), #-- solved

          @("Front",0,0,"Left",0,2,"Top",2,0,"U"),
          @("Front",0,2,"Top",2,2,"Right",0,0,"B","UC","BC"),
          @("Front",2,0,"Bottom",0,0,"Left",2,2,"F","U","FC"),
          @("Front",2,2,"Right",2,0,"Bottom",0,2,"FC","UC","F")
      )
      
      $movesForCornerLocationWRG = @(
          @("Top",0,0,"Left",0,0,"Back",0,2,"UC"), #fixed
          @("Top",0,2,"Back",0,0,"Right",0,2,"U","U"), #fixed
          @("Top",2,0,"Front",0,0,"Left",0,2,"LC","U","L"), #fixed
          @("Top",2,2,"Right",0,0,"Front",0,2,"U"), #fixed

          @("Right",0,0,"Front",0,2,"Top",2,2,"U"),
          @("Right",0,2,"Top",0,2,"Back",0,0,"L","UC","LC"),
          @("Right",2,0,"Bottom",0,2,"Front",2,2,"R","U","RC"),
          @("Right",2,2,"Back",2,0,"Bottom",2,2,"RC","UC","R"), #blocked

          @("Back",0,0,"Right",0,2,"Top",0,2,"U","U"),
          @("Back",0,2,"Top",0,0,"Left",0,0,"U"),
          @("Back",2,0,"Bottom",2,2,"Right",2,2,"BC","U","B"), #blocked
          @("Back",2,2,"Left",2,0,"Bottom",2,0,"BC","UC","B"), #fixed

          @("Left",0,0,"Back",0,2,"Top",0,0,"UC"),
          @("Left",0,2,"Top",2,0,"Front",0,0,"U","U"),
          @("Left",2,0,"Bottom",2,0,"Back",2,2,"L","U","LC"),
          @("Left",2,2,"Front",2,0,"Bottom",0,0,"LC","UC","L"), #fixed

          @("Bottom",0,0,"Left",2,2,"Front",2,0,"LC","UC","L"),
          @("Bottom",0,2,"Front",2,2,"Right",2,0,"R","U","RC"),
          @("Bottom",2,0,"Back",2,2,"Left",2,0),
          @("Bottom",2,2,"Right",2,2,"Back",2,0,"B","U","BC"), #blocked

          @("Front",0,0,"Left",0,2,"Top",2,0,"BC","U","B"), # fixed
          @("Front",0,2,"Top",2,2,"Right",0,0,"UC"),
          @("Front",2,0,"Bottom",0,0,"Left",2,2,"F","UC","FC"),
          @("Front",2,2,"Right",2,0,"Bottom",0,2,"FC","UC","F")
      )
      
      $movesForCornerLocationWGO = @(
          @("Top",0,0,"Left",0,0,"Back",0,2,"U","U"), #fixed
          @("Top",0,2,"Back",0,0,"Right",0,2,"U"),#fixed
          @("Top",2,0,"Front",0,0,"Left",0,2,"UC"), #fixed
          @("Top",2,2,"Right",0,0,"Front",0,2,"R","UC","RC"), #fixed

          @("Right",0,0,"Front",0,2,"Top",2,2,"LC","U","L"), #fixed
          @("Right",0,2,"Top",0,2,"Back",0,0,"UC"), #fixed
          @("Right",2,0,"Bottom",0,2,"Front",2,2,"R","U","RC"), #fixed
          @("Right",2,2,"Back",2,0,"Bottom",2,2,"RC","UC","R"), #blocked

          @("Back",0,0,"Right",0,2,"Top",0,2,"U"), #fixed 
          @("Back",0,2,"Top",0,0,"Left",0,0,"F","UC","FC"), #fixed
          @("Back",2,0,"Bottom",2,2,"Right",2,2,"BC","U","B"), #blocked
          @("Back",2,2,"Left",2,0,"Bottom",2,0,"B","UC","B"), #blocked

          @("Left",0,0,"Back",0,2,"Top",0,0,"U","U"), #fixed
          @("Left",0,2,"Top",2,0,"Front",0,0,"U"), #fixed
          @("Left",2,0,"Bottom",2,0,"Back",2,2,"LC","UC","L"), #blocked
          @("Left",2,2,"Front",2,0,"Bottom",0,0,"LC","UC","L"), #fixed

          @("Bottom",0,0,"Left",2,2,"Front",2,0,"LC","UC","L"), #blocked
          @("Bottom",0,2,"Front",2,2,"Right",2,0,"R","U","RC"), #fixed
          @("Bottom",2,0,"Back",2,2,"Left",2,0,"R","U","RC"), #blocked
          @("Bottom",2,2,"Right",2,2,"Back",2,0,"B","U","BC"), #blocked

          @("Front",0,0,"Left",0,2,"Top",2,0,"UC"), #fixed
          @("Front",0,2,"Top",2,2,"Right",0,0,"U","U"), #fixed
          @("Front",2,0,"Bottom",0,0,"Left",2,2,"F","U","FC"), #fixed
          @("Front",2,2,"Right",2,0,"Bottom",0,2,"FC","UC","F") #fixed
      )

      $movesForCornerLocationWOB = @(
          @("Top",0,0,"Left",0,0,"Back",0,2,"U","U"), #fixed
          @("Top",0,2,"Back",0,0,"Right",0,2,"U"),#fixed
          @("Top",2,0,"Front",0,0,"Left",0,2,"UC"), #fixed
          @("Top",2,2,"Right",0,0,"Front",0,2,"R","UC","RC"), #fixed

          @("Right",0,0,"Front",0,2,"Top",2,2,"UC"), #fixed
          @("Right",0,2,"Top",0,2,"Back",0,0,"U","U"), #fixed
          @("Right",2,0,"Bottom",0,2,"Front",2,2,"R","U","RC"), #fixed
          @("Right",2,2,"Back",2,0,"Bottom",2,2,"RC","UC","R"), #blocked

          @("Back",0,0,"Right",0,2,"Top",0,2,"FC","U","F"), #fixed
          @("Back",0,2,"Top",0,0,"Left",0,0,"UC"), #fixed
          @("Back",2,0,"Bottom",2,2,"Right",2,2,"BC","U","B"), #blocked
          @("Back",2,2,"Left",2,0,"Bottom",2,0,"B","UC","B"), #blocked

          @("Left",0,0,"Back",0,2,"Top",0,0,"U"), #fixed
          @("Left",0,2,"Top",2,0,"Front",0,0,"R","UC","RC"), #fixed
          @("Left",2,0,"Bottom",2,0,"Back",2,2,"LC","UC","L"), #blocked
          @("Left",2,2,"Front",2,0,"Bottom",0,0,"LC","UC","L"), #blocked

          @("Bottom",0,0,"Left",2,2,"Front",2,0,"LC","UC","L"), #blocked
          @("Bottom",0,2,"Front",2,2,"Right",2,0,"R","U","RC"), #blocked
          @("Bottom",2,0,"Back",2,2,"Left",2,0,"R","U","RC"), #blocked
          @("Bottom",2,2,"Right",2,2,"Back",2,0,"B","U","BC"), #blocked

          @("Front",0,0,"Left",0,2,"Top",2,0,"U","U"), #fixed
          @("Front",0,2,"Top",2,2,"Right",0,0,"U"), #fixed
          @("Front",2,0,"Bottom",0,0,"Left",2,2,"F","U","FC"), #blocked
          @("Front",2,2,"Right",2,0,"Bottom",0,2,"FC","UC","F") #fixed
       )   
          
          
      function findMoveSetIndex($corner) {
          searchCornerPiecesCW
          switch($corner) {
              "WBR" { $selMovesArray = $movesForCornerLocationWBR; $foundIndex = 0 }
              "WRG" { $selMovesArray = $movesforCornerLocationWRG; $foundIndex = 1 }
              "WGO" { $selMovesArray = $movesforCornerLocationWGO; $foundIndex = 2 }
              "WOB" { $selMovesArray = $movesforCornerLocationWOB; $foundIndex = 3 }
              default { Write-Host "Error" }
          }
          $arrayNotFound = $true
          while ($arrayNotFound) {
              for ($i = 0; $i -le 23; $i++) {
              
                  $currectArrayIsCorrect = $true
                  for ($j = 0; $j -le 8; $j++) {
                      $selElFound = $foundCornerLocations[$foundIndex][$j]
                      $selElMoves = $selMovesArray[$i][$j]
                      if ($selElFound -ne $selElMoves) {
                          $currectArrayIsCorrect = $false
                      }
                  }
                  if ($currectArrayIsCorrect) {
                      $arrayNotFound = $false
                      Write-Host "$executor Found correct Moveset [ $i ] for Corner piece: [ $corner ]"
                      return $i
                  } 
              }
          }
      }
      
      function applyMoves($corner, $index) {
          switch($corner) {
              "WBR" { $selMovesArray = $movesForCornerLocationWBR }
              "WRG" { $selMovesArray = $movesForCornerLocationWRG }
              "WGO" { $selMovesArray = $movesForCornerLocationWGO }
              "WOB" { $selMovesArray = $movesForCornerLocationWOB }
              default { Write-Host "Error" }
          }
          $arrayLength = $selMovesArray.Length -1
          for($i = 9; $i -le $arrayLength; $i++) {
              $selMove = $selMovesArray[$index][$i]
              $this.Move("$selMove")
          }
          
      
      }
      
      function checkIfCornerSolved($corner) {
          switch($corner) {
              "WBR" { $correctTile2 = "B"; $correctTile3 = "R" }
              "WRG" { $correctTile2 = "R"; $correctTile3 = "G" }
              "WGO" { $correctTile2 = "G"; $correctTile3 = "O" }
              "WOB" { $correctTile2 = "O"; $correctTile3 = "B" }
          }
          switch($corner) {
              "WBR" { $fTile2 = $this.Right[2][2]; $fTile3 = $this.Back[2][0]; $fTile1 = $this.Bottom[2][2] }
              "WRG" { $fTile2 = $this.Back[2][2]; $fTile3 = $this.Left[2][0]; $fTile1 = $this.Bottom[2][0] }
              "WGO" { $fTile2 = $this.Left[2][2]; $fTile3 = $this.Front[2][0]; $fTile1 = $this.Bottom[0][0] }
              "WOB" { $fTile2 = $this.Front[2][2]; $fTile3 = $this.Right[2][0]; $fTile1 = $this.Bottom[0][2] }
          }
          
          $cornerIsSolved = $false
          
          if ( $fTile1 -eq "W" ) {
              Write-Host "$executor Corner is valid (1/3)"
              if ( $fTile2 -eq $correctTile2 ) {
                  Write-Host "$executor Corner is valid (2/3)"
                  if ( $fTile3 -eq $correctTile3 ) {
                      Write-Host "$executor Corner is valid (3/3)"
                      $cornerIsSolved = $true
                  }
              } 
          }
          
          if ($cornerIsSolved) {
              return $true
          } else {
              return $false
          }
      }
      
      function solveCorner($corner) {
          $alreadySolved = checkIfCornerSolved "$corner"
          if ($alreadySolved) {
              Write-Host "$executor Already solved corner [ $corner ]"
          } else {
              $index = findMoveSetIndex "$corner"
              Write-Host "$index"
              applyMoves "$corner" $index
          }
      }
      
      function printFoundCornerLocations() {
          Write-Host
          Write-Host "------------------------------------------"
          for($i = 0; $i -le 3; $i++) {
              Write-Host "$executor Printing [ Array $i ]"
              Write-Host " " -NoNewline
              for($j = 0; $j -le 8; $j++) {    
                  $elementToPrint = $foundCornerLocations[$i][$j]                  
                  Write-Host "$elementToPrint " -NoNewline
              }
              Write-Host
          } 
      }
     
      # ----------------------------------------- solve edges ------------------------------------------------- 
      
      $moveSets = @(
          ("UC","RC","U","R","U","B","UC","BC"), #BR
          ("U","B","UC","BC","UC","RC","U","R"), #RB
          ("UC","BC","U","B","U","L","UC","LC"), #RG
          ("U","L","UC","LC","UC","BC","U","B"), #GR
          ("UC","LC","U","L","U","F","UC","FC"), #GO
          ("U","F","UC","FC","UC","LC","U","L"), #OG
          ("UC","FC","U","F","U","R","UC","RC"), #OB
          ("U","R","UC","RC","UC","FC","U","F") #BO
      )
      
      function applyMoveSet($index) {
          for($i = 0; $i -le 7; $i++) {
              $selMove = $moveSets[$index][$i]
              $this.Move("$selMove")
          }
      }
      
      $sides = @("Front","Right","Back","Left")
       
      #-------------------- BR ---------------------  

      function findLayerBR() {
          for($i = 0; $i -le 3; $i++) {
              $foundTile1 = $this.Right[1][2]
              $foundTile2 = $this.Back[1][0]
              $foundEdgePiece = $foundTile1 + $foundTile2
              if ($foundEdgePiece -eq "RB") {
                  applyMoveSet 1
              } elseif ($foundEdgePiece -eq "BR") {
                  applyMoveSet 1
              }
              $this.Move("Y")
          }
      }

      function solveBR() {
          Write-Host "$executor Trying to solve Edge piece [ BR ]"
          Write-Host "-------------------------------------------------------------------"
          findLayerBR
          for($i = 0; $i -le 4; $i++) {
              $tile1 = $this.Top[0][1] 
              $tile2 = $this.Back[0][1]
              $edgePiece = $tile1 + $tile2
              Write-Host "$edgePiece"
              if ($edgePiece -eq "BR") {
                  Write-Host "$executor Found Edge piece [ BR ] "
                  Write-Host "$executor Executing moveset [ 0 ]"
                  applyMoveSet 0
              } elseif ($edgePiece -eq "RB") {
                  Write-Host "$executor Found Edge piece [ RB ] "
                  $this.Move("U")
                  Write-Host "$executor Executing moveset [ 1 ]"
                  applyMoveSet 1
                  $this.Move("UC")
              }
              Write-Host "$executor Rotating the top layer..."
              Write-Host "----------------------------------------"
              $this.Move("U")
          }
      }
      
      #-------------------- RG ---------------------  

      function findLayerRG() {
          for($i = 0; $i -le 3; $i++) {
              $foundTile1 = $this.Back[1][2]
              $foundTile2 = $this.Left[1][0]
              $foundEdgePiece = $foundTile1 + $foundTile2
              if ($foundEdgePiece -eq "GR") {
                  applyMoveSet 3
              } elseif ($foundEdgePiece -eq "RG") {
                  applyMoveSet 3
              }
              $this.Move("Y")
          }
      }

      function solveRG() {
          Write-Host "$executor Trying to solve Edge piece [ RG ]"
          Write-Host "-------------------------------------------------------------------"
          findLayerRG
          for($i = 0; $i -le 4; $i++) {
              $tile1 = $this.Top[1][0] 
              $tile2 = $this.Left[0][1]
              $edgePiece = $tile1 + $tile2
              Write-Host "$edgePiece"
              if ($edgePiece -eq "RG") {
                  Write-Host "$executor Found Edge piece [ RG ] "
                  Write-Host "$executor Executing moveset [ 2 ]"
                  applyMoveSet 2
              } elseif ($edgePiece -eq "GR") {
                  Write-Host "$executor Found Edge piece [ GR ] "
                  $this.Move("U")
                  Write-Host "$executor Executing moveset [ 3 ]"
                  applyMoveSet 3
                  $this.Move("UC")
              }
              Write-Host "$executor Rotating the top layer..."
              Write-Host "----------------------------------------"
              $this.Move("U")
          }
      }
      
      #-------------------- GO ---------------------  

      function findLayerGO() {
          for($i = 0; $i -le 3; $i++) {
              $foundTile1 = $this.Left[1][2]
              $foundTile2 = $this.Front[1][0]
              $foundEdgePiece = $foundTile1 + $foundTile2
              if ($foundEdgePiece -eq "OG") {
                  applyMoveSet 5
              } elseif ($foundEdgePiece -eq "GO") {
                  applyMoveSet 5
              }
              $this.Move("Y")
          }
      }

      function solveGO() {
          Write-Host "$executor Trying to solve Edge piece [ GO ]"
          Write-Host "-------------------------------------------------------------------"
          findLayerGO
          for($i = 0; $i -le 4; $i++) {
              $tile1 = $this.Top[2][1] 
              $tile2 = $this.Front[0][1]
              $edgePiece = $tile1 + $tile2
              Write-Host "$edgePiece"
              if ($edgePiece -eq "GO") {
                  Write-Host "$executor Found Edge piece [ GO ] "
                  Write-Host "$executor Executing moveset [ 4 ]"
                  applyMoveSet 4
              } elseif ($edgePiece -eq "OG") {
                  Write-Host "$executor Found Edge piece [ OG ] "
                  $this.Move("U")
                  Write-Host "$executor Executing moveset [ 5 ]"
                  applyMoveSet 5
                  $this.Move("UC")
              }
              Write-Host "$executor Rotating the top layer..."
              Write-Host "----------------------------------------"
              $this.Move("U")
          }
      }
      
      #-------------------- OB ---------------------  

      function findLayerOB() {
          for($i = 0; $i -le 3; $i++) {
              $foundTile1 = $this.Front[1][2]
              $foundTile2 = $this.Right[1][0]
              $foundEdgePiece = $foundTile1 + $foundTile2
              if ($foundEdgePiece -eq "BO") {
                  applyMoveSet 7
              } elseif ($foundEdgePiece -eq "OB") {
                  applyMoveSet 7
              }
              $this.Move("Y")
          }
      }

      function solveOB() {
          Write-Host "$executor Trying to solve Edge piece [ OB ]"
          Write-Host "-------------------------------------------------------------------"
          findLayerOB
          for($i = 0; $i -le 4; $i++) {
              $tile1 = $this.Top[1][2] 
              $tile2 = $this.Right[0][1]
              $edgePiece = $tile1 + $tile2
              Write-Host "$edgePiece"
              if ($edgePiece -eq "OB") {
                  Write-Host "$executor Found Edge piece [ OB ] "
                  Write-Host "$executor Executing moveset [ 6 ]"
                  applyMoveSet 6
              } elseif ($edgePiece -eq "BO") {
                  Write-Host "$executor Found Edge piece [ BO ] "
                  $this.Move("U")
                  Write-Host "$executor Executing moveset [ 7 ]"
                  applyMoveSet 7
                  $this.Move("UC")
              }
              Write-Host "$executor Rotating the top layer..."
              Write-Host "----------------------------------------"
              $this.Move("U")
          }
      }
      
      function solveF2LMain() {   
          searchCornerPiecesCW
          printFoundCornerLocations
          Write-Host "-----------------------------------------------------------------------------------------"
          solveCorner "WBR"
          solveCorner "WBR"
          solveCorner "WBR"
          $this.printCube()
          Write-Host "-----------------------------------------------------------------------------------------"
          solveCorner "WRG"
          solveCorner "WRG"
          solveCorner "WRG"
          $this.printCube()
          Write-Host "-----------------------------------------------------------------------------------------"
          solveCorner "WGO"
          solveCorner "WGO"
          solveCorner "WGO"
          solveCorner "WGO"
          $this.printCube()
          Write-Host "-----------------------------------------------------------------------------------------"
          solveCorner "WOB"
          solveCorner "WOB"
          solveCorner "WOB"
          solveCorner "WOB"
          $this.printCube()
          Write-Host "-----------------------------------------------------------------------------------------"
          
          solveBR
          solveRG
          solveGO
          solveOB

          $this.printCube()
      }
      
      solveF2LMain
      
  }

  [void] SolveOLL() {
      $executor = "[OLL-SOLVER]:"
      
      function findMoveSet($moveSet) {
          switch($moveSet) {
              "XXXXYXXXXYYYXYXYYYXYX" { return 0 }
              "XXXXYXXXXYYYXYYXYXYYX" { return 1 }
              "XXXXYXXXYXYYXYYXYYXYX" { return 2 }
              "XXYXYXXXXYYXXYXYYXYYX" { return 3 }
              "YXXXYXXXYXYXYYXXYYXYX" { return 4 }
              "YXYXYXYXYXYXXYXXYXXYX" { return 5 }
              "YXYXYXXXXYYXXYXXYYXYX" { return 6 }
              "XXXXYXYXYXYXYYYXYXXYX" { return 7 }
              "XYXXYXXYXYYYXXYXYXYXX" { return 8 }
              "XYXXYXXYXYYYXXXYYYXXX" { return 9 }
              "XXXYYYXXXYXYXYYXXXYYX" { return 10 }
              "XXXYYYXXXYXYXYXYXYXYX" { return 11 }
              "XYXYYYXYXYXYXXYXXXYXX" { return 12 }
              "XYXYYYXYXYXYXXXYXYXXX" { return 13 }
              "XYXYYYXYYXXXYXXYXXYXX" { return 14 }
              "XYXYYYXYYXXYXXYXXYXXX" { return 15 }
              "YYXYYYYYXXXXYXXXXXXXY" { return 16 }
              "YYYYYYXYXXXXXXXXXXYXY" { return 17 }
              "YYXYYYXYYXXXYXXXXYXXX" { return 18 }
              "YXYYYXYYYXYXXYXXXXXXX" { return 19 }
              "YXYYYYYXYXXXXYXXXXXYX" { return 20 } #fixed
              "XYXYYXYXXXYYXXYXXXXYY" { return 21 }
              "YYXYYXXXYXYYXXXXXXYYX" { return 22 }
              "XYXYYXXXYXYXYXXYXXYYX" { return 23 }
              "XYXYYXYXYXYXYXYXXXXYX" { return 24 }
              "XYXYYXXXXXYXYXXYXYXYY" { return 25 }
              "XYXYYXXXXXYXYXYXXXYYY" { return 26 }
              "XYXXYYYXYXXXYXYXYXXYX" { return 27 }
              "XYYXYYXXXYXXXXXYYXYYX" { return 28 }
              "XYXXYYXXXYXYXXYXYXYYX" { return 29 } #fixed
              "XYYXYYYXXYXXXXYXYXXYX" { return 30 }
              "XYXXYYXXXXXXYXYXYXYYY" { return 31 }
              "XYXXYYXXXXXXYXXYYYXYY" { return 32 }
              "XXYYYXXYXXYXXYYXXYXXY" { return 33 }
              "YXXYYXXYXYYXYYXXXXYXX" { return 34 }
              "XXXYYXXYYXYXYYXYXXYXX" { return 35 } #fixed
              "YXYYYXXYXYYXXYXXXYXXX" { return 36 }
              "XXXXYYXYXXXXYYXYYYXXY" { return 37 }
              "XXXXYYYYXXXYXYYXYXXXY" { return 38 }
              "XXXXYYXYYXXYXYYXYYXXX" { return 39 }
              "YXYXYYXYXYXXXYXXYYXXX" { return 40 }
              "YYXXYXYYXYYYXXXXYXXXX" { return 41 }
              "XXXYYYYXYXXYXYXYXXXYX" { return 42 }
              "XXXYYYXXYXXXYYXYXXYYX" { return 43 }
              "XXXYYYYXXXXYXYYXXXXYY" { return 44 }
              "XXXYYYXXYXXYXYYXXYXYX" { return 45 }
              "XXXYYYYXXYXXYYXYXXXYX" { return 46 }
              "YYXYYXYXXYYYXXXXXXXYX" { return 47 }
              "XYYXYYXXYXXXXXYXYXYYX" { return 48 }
              "YYXYYXYXXXYXYXXXXXXYY" { return 49 }
              "XYYXYYXXYXXXXXXYYYXYX" { return 50 }
              "XXYYYYXXYXXXXYXYXYXYX" { return 51 }
              "XXYYYYXXYXXXXYYXXXYYX" { return 52 }
              "XXYXYYYYXXXXXYXYYXXXY" { return 53 }
              "YXXYYXXYYXYYXYXXXXYXX" { return 54 }
              "YXXYYYXXYXXXYYXXXYXYX" { return 55 }
              "XXYYYYYXXYXXXYYXXXXYX" { return 56 }
              default { Write-Host "$executor No Moveset found."; return 57 }


          }
      }

	    $moveSets = @(
          ("R", "U", "BC", "LD", "U", "LDC", "LDC", "XC", "UC", "RC", "F", "R", "FC"),  # 0 --fixed
          ("U","RC", "F", "R", "FC", "U", "U", "RC", "F", "R", "YC", "R", "R", "U", "U", "R"),  # 1 --fixed
          ("Y", "LC", "R", "R", "B", "RC", "B", "L", "UC", "UC", "LC","B", "MC"),  # 2 --fixed
          ("RC", "U", "U", "X", "RC", "U", "R", "UC", "Y", "RC", "UC", "RC", "U", "RC", "F"),  # 3 --fixed
          ("R", "U", "RC", "U", "RC", "F", "R", "FC", "U", "U", "RC", "F", "R", "FC"),  # 4 --fixed
          ("MC", "U", "U", "M", "U", "U", "MC", "U", "M", "U", "U", "MC","U","U","M"),  # 5 --fixed
          ("RC","U","U","F","R","U","RC","UC","YC","R","R","U","U","XC","R","U"),  # 6 --fixed
          ("F", "R", "U", "RC", "U", "YC", "RC", "U", "U", "RC", "F", "R", "FC"),  # 7 --fixed
          ("RC", "UC", "Y", "LC", "U", "LC", "YC", "L", "F", "LC", "F", "R"),  # 8 --fixed
          ("R", "UC", "Y", "R", "R", "D", "RC", "U", "U", "R", "DC", "R", "R", "DD", "RC"),  # 9 --fixed
          ("F", "U", "R", "UC", "RC", "U", "R", "UC", "RC", "FC"),  # 10 --fixed
          ("LC", "BC", "L", "UC", "RC", "U", "R", "UC", "RC", "U", "R", "LC", "B", "L"),  # 11 --fixed
          ("L", "UC", "RC", "U", "LC", "U", "R", "U", "RC", "U", "R"),  # 12 --fixed
          ("R", "U", "RC", "U", "R", "UC", "RC", "U", "R", "U", "U", "RC"),  # 13 --fixed
          ("LC", "U", "R", "UC", "L", "U", "RC"),  # 14 --fixed
          ("RC","U","U","R","U","RC","U","R"),  # 15 --fixed
          ("RC", "FC", "L", "F", "R", "FC", "LC", "F"),  # 16 --fixed
          ("R","R","D","RC","U","U","R","DC","RC","U","U","RC"),  # 17 --fixed
          ("RC", "FC", "LC", "F", "R", "FC", "L", "F"),  # 18 --fixed 
          ("MC", "UC", "M", "U", "U", "MC", "UC", "M"),  # 19 --fixed
          ("LC","R","U","RC","UC","L","RC","F","R","FC"),  # 20 --fixed
          ("L","F","RC","F","R","F","F","LC"),  # 21 --fixed
          ("F","RC","FC","R","U","R","UC","RC"),  # 22 --fixed
          ("RC", "UC", "R", "YC", "XC", "R", "UC", "RC", "F", "R", "U", "RC"),  # 23 --fixed
          ("UC", "R", "U", "U", "RC", "UC", "R", "UC", "R", "R", "YC", "RC", "UC", "R", "U", "B"),  # 24 --fixed
          ("F", "R", "U", "RC", "UC", "R", "U", "RC", "UC", "FC"),  # 25 --fixed
          ("L","FC","LC","F","U","U","L","L","YC","L","F","LC","F"),  # 26  --fixed
          ("UC", "RC", "U", "U", "R", "U", "RC", "U", "R", "R", "Y", "R", "U", "RC", "UC", "FC"),  # 27 --fixed
          ("RD", "U", "U", "RC", "UC", "R", "UC", "RDC"),  # 28  --fixed
          ("FC","LC","UC","L","U","LC","UC","L","U","F"),  # 29 --fixed
          ("RC","U","U","LD","R","UC","RC","U","LDC","U","U","R"),  # 30 --fixed
          ("RC", "F", "R", "FC", "U", "U", "R", "R", "Y", "RC", "FC", "R", "FC"),  # 31 --fixed
          ("RC","F","RC","FC","R","R","U","U","XC","UC","R","U","RC"),  # 32 --fixed
          ("R", "U", "RC", "Y", "RC", "F", "R", "UC", "RC", "FC", "R"),  # 33 --fixed
          ("LC", "BC", "L", "UC", "RC", "U", "R", "LC", "B", "L"),  # 34 --fixed
          ("U", "U", "RD", "R", "R", "UC", "R", "UC", "RC", "U", "U", "R", "UC", "M"),  # 35 --fixed
          ("XC","UC","R","UC","RC","RC","F","X","R","U","RC","UC","R","B","B"),  # 36 --fixed
          ("L","UC","YC","RC","UC","UC","RC","U","R","UC","R","U","U","R","DDC","LC"),  # 37 --fixed
          ("U","U","LDC","L","L","U","LC","U","L","U","U","LC","U","M"),  # 38 --fixed
          ("RDC","U","U","R","U","RC","U","RD"),  # 39 --fixed
          ("RC","RC","U","RC","BC","R","UC","RC","RC","U","LD","U","LDC"),  # 40 --fixed
          ("R", "U", "XC", "R", "UC", "RC", "U", "X", "UC", "RC"),  # 41 --fixed
          ("R", "U", "RC", "UC", "X", "DC", "RC", "U", "R", "EC"),  # 42--fixed
          ("RC", "F", "R", "U", "RC", "FC", "R", "Y", "L", "UC", "LC"),  # 43 --fixed
          ("L", "FC", "LC", "UC", "L", "F", "LC", "YC", "RC", "U", "R"),  # 44 --fixed
          ("LC", "BC", "L", "RC", "UC", "R", "U", "LC", "B", "L"),  # 45 --fixed
          ("R","B","RC","L","U","LC","UC","R","BC","RC"),  # 46 --fixed
          ("F", "U", "R", "UC", "RC", "FC"),  # 47 --fixed
          ("RC","DDC","L","DD","R","UC","RC","FC","R"),  # 48 --fixed
          ("L", "DD", "RC", "DDC", "LC", "U", "L", "F", "LC"),  # 49 --fixed
          ("FC", "UC", "LC", "U", "L", "F"),  # 50 --fixed
          ("F","R","U","RC","UC","FC"),  # 51 --fixed
          ("R", "U", "RC", "UC", "RC", "F", "R", "FC"),  # 52 --fixed
          ("L", "U", "LC", "U", "L", "UC", "LC", "UC", "YC", "YC", "RC", "F", "R", "FC"),  # 53 --fixed
          ("RC", "UC", "R", "UC", "RC", "U", "R", "U", "Y", "F", "RC", "FC", "R"),  # 54 --fixed
          ("RC","F","R","U","RC","UC","Y","LC","DD","R"),  # 55 --fixed
          ("L", "FC", "LC", "UC", "L", "U", "YC", "R", "DDC", "LC")  # 56 --fixed
          
      )
      # 1. read all of top layer
      # 2.solve based on value
      function storeTopLayer() {
          
          $topLayer = ""
          # ----- Top Side ------
          for($i = 0; $i -le 2; $i++) {
              for($j = 0; $j -le 2; $j++) {
                  $selTile = $this.Top[$i][$j]
                  if($selTile -eq "Y") {
                      $topLayer = $topLayer + $selTile 
                  } else {
                      $topLayer = $topLayer + "X"
                  }
              }
          }
          # ----- other sides -----
          $sides = @("Right","Back","Left","Front")
          for($k = 0; $k -le 3; $k++) {
              for($l = 0; $l -le 2; $l++) {
                  $selSide = $sides[$k]
                  $selTile = $this."$selSide"[0][$l]
                  if($selTile -eq "Y") {
                      $topLayer = $topLayer + $selTile 
                  } else {
                      $topLayer = $topLayer + "X"
                  }
                  
              }
          }
          # print to check
          Write-Host "$executor Top Layer = $topLayer"
          
          #---------------------------------------
          return $topLayer
      }
      
      function solveTopLayer($topLayer) {
          $moveSetNotFound = $true
          $index = findMoveSet $topLayer
          while ($moveSetNotFound) {
              $index = findMoveSet $topLayer
              if($index -eq 57) {
                  Write-Host "$executor Rotating the Top layer to find the correct moveset..."
                  $this.Move("U")
                  $topLayer = storeTopLayer

              } else {
                  Write-Host "$executor Success! The cube is ready for the moveset"
                  $moveSetNotFound = $false
              }
          }
          $index = findMoveSet $topLayer
          
          Write-Host "$executor The Correct Index is: [ $index ]"
          return $index
      
      }
      
      function ApplyMoveSet($index) {
          $this.printCube()
          $selMoveSet = $moveSets[$index]
          $arrayLength = $selMoveSet.Length - 1
          Write-Host "$executor Selected Array [ $index ] which has length: [ $arrayLength ]"
          Write-Host "$executor Aligning top layer..."
          #$this.Move("U") # -- align
          for ($i = 0; $i -le $arrayLength; $i++) {
              $selMove = $selMoveset[$i]
              Write-Host "$executor Executing move [ $selMove ]"
              $this.Move("$selMove")
          }
          $this.rotateCube()
          Write-Host "$executor Selected Array [ $index ] which has length: [ $arrayLength ]"
          
      }


      function solveOLLMain() {
          $topLayer = storeTopLayer
          $index = solveTopLayer $topLayer
          $this.printCube()
          Write-Host "$executor Top layer = $topLayer"
          ApplyMoveSet $index
          Write-Host "$executor Top layer was = $topLayer"
          $this.printCube()
      }

      solveOLLMain
  
  }
  
  [void] SolvePLL() {
      $executor = "[PLL-SOLVER]:"
      
      function findMoveSet($moveSet) {
          Write-Host "$executor Searching for the correct Moveset using [ $moveSet ]"
          $moveSet = "$moveSet"
          switch($moveSet) {
              "41032567" { return 0 } #fixed A1 -
              "21634507" { return 1 } #fixed A2 -
              "07234165" { return 2 } #fixed U1 
              "05234761" { return 3 } #fixed U2
              "05274163" { return 4 } #fixed H
              "25034167" { return 5 } #fixed T -
              "01452367" { return 6 } #fixed J1
              "27034561" { return 7 } #fixed J2
              "01432765" { return 8 } #fixed R1
              "07432561" { return 9 } #fixed R2 -
              "43210567" { return 10 } #fixed V
              "03652147" { return 11 } #fixed G1
              "41276305" { return 12 } #fixed G2
              "47236105" { return 13 } #fixed G3 -
              "01652743" { return 14 } #fixed G4
              "65234107" { return 15 } #fixed F
              "07254361" { return 16 } #fixed Z
              "41250367" { return 17 } #fixed Y -
              "41270563" { return 18 } #fixed N1
              "01674523" { return 19 } #fixed N2
              "21036547" { return 20 } #fixed E
              default { return 21 }
          }
      }
      
      $moveSets = @(
          ("X", "RC", "U", "RC", "D", "D", "R", "UC", "RC", "D", "D", "R", "R"),
          ("XC", "R", "UC", "R", "D", "D", "RC", "U", "R", "D", "D", "R", "R"),
          ("R", "R", "U", "R", "U", "RC", "UC", "RC", "UC", "RC", "U", "RC"),
          ("R", "UC", "R", "U", "R", "U", "R", "UC", "RC", "UC", "R", "R"),
          ("M", "M", "U", "M", "M", "U", "U", "M", "M", "U", "M", "M"),
          ("R", "U", "RC", "UC", "RC", "F", "R", "R", "UC", "RC", "UC", "R", "U", "RC", "FC"),
          ("RC", "U", "LC", "U", "U", "R", "UC", "RC", "U", "U", "R", "L", "UC"),
          ("R", "U", "RC", "FC", "R", "U", "RC", "UC", "RC", "F", "R", "R", "UC", "RC", "UC"),
          ("L", "UC", "UC", "LC", "UC", "UC", "L", "FC", "LC", "UC", "L", "U", "L", "F", "LC", "LC", "U"),
          ("RC", "U", "U", "R", "U", "U", "RC", "F", "R", "U", "RC", "UC", "RC", "FC", "R", "R", "UC"),
          ("RC", "U", "RC", "DDC", "RC", "FC", "R", "R", "UC", "RC", "U", "RC", "F", "R", "F"),
          ("R", "R", "UD", "RC", "U", "RC", "UC", "R", "UDC", "R", "R", "YC", "RC", "U", "R"),
          ("RC", "UC", "R", "Y", "R", "R", "UD", "RC", "U", "R", "UC", "R", "UDC", "R", "R"),
          ("R", "R", "UDC", "R", "UC", "R", "U", "RC", "UD", "R", "R", "Y", "R", "UC", "RC"),
          ("R", "U", "RC", "YC", "R", "R", "UDC", "R", "UC", "RC", "U", "RC", "UD", "R", "R"),
          ("RC", "U", "U", "RC", "DDC", "RC", "FC", "R", "R", "UC", "RC", "U", "RC", "F", "R", "UC", "F"),
          ("M", "M", "U", "M", "M", "U", "MC", "U", "U", "M", "M", "U", "U", "MC", "U", "U"),
          ("F", "R", "UC", "RC", "UC", "R", "U", "RC", "FC", "R", "U", "RC", "UC", "RC", "F", "R", "FC"),
          ("L", "UC", "R", "U", "U", "LC", "U", "RC", "L", "UC", "R", "U", "U", "LC", "U", "RC", "U"),
          ("RC", "U", "LC", "U", "U", "R", "UC", "L", "RC", "U", "LC", "U", "U", "R", "UC", "L", "UC"),
          ("XC", "R", "UC", "RC", "D", "R", "U", "RC", "UD", "UD", "RC", "U", "R", "D", "RC", "UC", "R")
      )
      
      function applyMoveSet($index) {
          Write-Host "--------------------------------------------------------------"
          $this.printCube()
          Write-Host "--------------------------------------------------------------"
          $selArray = $moveSets[$index]
          $arrayLength = $selArray.Length -1
          for($i = 0; $i -le $arrayLength; $i++) {
              $selMove = $selArray[$i]
              Write-Host "$executor Executing Move [ $selMove ]"
              $this.Move("$selMove")
          }
          $this.printCube()
          $this.rotateCube()
          Write-Host "--------------------------------------------------------------"
      }
      
      $topLayer = @("-","-","-","-","-","-","-","-")
      $topLayerInt = @(0,0,0,0,0,0,0,0)

      function storeTopLayer() {
          $selTile0 = $this.Front[0][2]
          $selTile1 = $this.Right[0][0]
          $selTile2 = $this.Right[0][1]
          $selTile3 = $this.Right[0][2]
          $selTile4 = $this.Back[0][0]
          $selTile5 = $this.Back[0][1]
          $selTile6 = $this.Back[0][2]
          $selTile7 = $this.Left[0][0]
          $selTile8 = $this.Left[0][1]
          $selTile9 = $this.Left[0][2]
          $selTile10 = $this.Front[0][0]
          $selTile11 = $this.Front[0][1]
          
          $element0 = $selTile0 + $selTile1
          $element1 = $selTile3 + $selTile4
          $element2 = $selTile6 + $selTile7
          $element3 = $selTile9 + $selTile10
          
          $topLayer[0] = $element0
          $topLayer[1] = $selTile2
          $topLayer[2] = $element1
          $topLayer[3] = $selTile5
          $topLayer[4] = $element2
          $topLayer[5] = $selTile8
          $topLayer[6] = $element3
          $topLayer[7] = $selTile11

      }
      
      # -------------------- CASE 1 --------------------
      function storeTopLayerInt1() {
          $moveSet = ""
          for($i = 0; $i -le 7; $i ++) {
              $selTopLayerElement = $topLayer[$i]
              switch($selTopLayerElement) {
                  "OB" { $topLayerInt[$i] = 0 }
                  "B" { $topLayerInt[$i] = 1 }
                  "BR" { $topLayerInt[$i] = 2 }
                  "R" { $topLayerInt[$i] = 3 }
                  "RG" { $topLayerInt[$i] = 4 }
                  "G" { $topLayerInt[$i] = 5 }
                  "GO" { $topLayerInt[$i] = 6 }
                  "O" { $topLayerInt[$i] = 7 }
              }
              $moveSet = $moveSet + $topLayerInt[$i]
          }
          return $moveSet
      }
      # -------------------- CASE 2 --------------------
      function storeTopLayerInt2() {
          $moveSet = ""
          for($i = 0; $i -le 7; $i ++) {
              $selTopLayerElement = $topLayer[$i]
              switch($selTopLayerElement) {
                  "OB" { $topLayerInt[$i] = 6 }
                  "B" { $topLayerInt[$i] = 7 }
                  "BR" { $topLayerInt[$i] = 0 }
                  "R" { $topLayerInt[$i] = 1 }
                  "RG" { $topLayerInt[$i] = 2 }
                  "G" { $topLayerInt[$i] = 3 }
                  "GO" { $topLayerInt[$i] = 4 }
                  "O" { $topLayerInt[$i] = 5 }
              }
              $moveSet = $moveSet + $topLayerInt[$i]
          }
          return $moveSet
      }
      # -------------------- CASE 3 --------------------
      function storeTopLayerInt3() {
          $moveSet = ""
          for($i = 0; $i -le 7; $i ++) {
              $selTopLayerElement = $topLayer[$i]
              switch($selTopLayerElement) {
                  "OB" { $topLayerInt[$i] = 4 }
                  "B" { $topLayerInt[$i] = 5 }
                  "BR" { $topLayerInt[$i] = 6 }
                  "R" { $topLayerInt[$i] = 7 }
                  "RG" { $topLayerInt[$i] = 0 }
                  "G" { $topLayerInt[$i] = 1 }
                  "GO" { $topLayerInt[$i] = 2 }
                  "O" { $topLayerInt[$i] = 3 }
              }
              $moveSet = $moveSet + $topLayerInt[$i]
          }
          return $moveSet
      }
      # -------------------- CASE 4 --------------------
      function storeTopLayerInt4() {
          $moveSet = ""
          for($i = 0; $i -le 7; $i ++) {
              $selTopLayerElement = $topLayer[$i]
              switch($selTopLayerElement) {
                  "OB" { $topLayerInt[$i] = 2 }
                  "B" { $topLayerInt[$i] = 3 }
                  "BR" { $topLayerInt[$i] = 4 }
                  "R" { $topLayerInt[$i] = 5 }
                  "RG" { $topLayerInt[$i] = 6 }
                  "G" { $topLayerInt[$i] = 7 }
                  "GO" { $topLayerInt[$i] = 0 }
                  "O" { $topLayerInt[$i] = 1 }
              }
              $moveSet = $moveSet + $topLayerInt[$i]
          }
          return $moveSet
      }
      
      function printTopLayer() {
          Write-Host "$executor Printing top layer..."
          foreach($piece in $topLayer) {
              Write-Host -NoNewline "$piece "
          }
          Write-Host
      }
      
      function printTopLayerInt() {
          Write-Host "$executor Printing top layer..."
          foreach($piece in $topLayerInt) {
              Write-Host -NoNewline "$piece "
          }
          Write-Host
      }
      
      # ------------------------------------------------
      function solveTopLayer1() {
          for($i = 0; $i -le 4; $i++) {
              storeTopLayer
              $moveSet = storeTopLayerInt1
              Write-Host "$executor Moveset = $moveSet"
              $index = findMoveSet $moveSet
              Write-Host "$executor Index = $index"
              if ($index -ne 21) {
                  Write-Host "$executor Executing Moveset [ $index ]"
                  applyMoveSet $index
                  break
              } else {
                  Write-Host "$executor could not find a Moveset, rotating the top layer..."
                  $this.Move("U")
                  $this.printCube()
              }
              
          }
          $this.rotateCube()
      }
      # ------------------------------------------------
      function solveTopLayer2() {
          for($i = 0; $i -le 4; $i++) {
              storeTopLayer
              $moveSet = storeTopLayerInt2
              Write-Host "$executor Moveset = $moveSet"
              $index = findMoveSet $moveSet
              Write-Host "$executor Index = $index"
              if ($index -ne 21) {
                  Write-Host "$executor Executing Moveset [ $index ]"
                  applyMoveSet $index
                  break
              } else {
                  Write-Host "$executor could not find a Moveset, rotating the top layer..."
                  $this.Move("U")
                  $this.printCube()
              }
              
          }
          $this.rotateCube()
      }
      # ------------------------------------------------
      function solveTopLayer3() {
          for($i = 0; $i -le 4; $i++) {
              storeTopLayer
              $moveSet = storeTopLayerInt3
              Write-Host "$executor Moveset = $moveSet"
              $index = findMoveSet $moveSet
              Write-Host "$executor Index = $index"
              if ($index -ne 21) {
                  Write-Host "$executor Executing Moveset [ $index ]"
                  applyMoveSet $index
                  break
              } else {
                  Write-Host "$executor could not find a Moveset, rotating the top layer..."
                  $this.Move("U")
                  $this.printCube()
              }
              
          }
          $this.rotateCube()
      }
      # ------------------------------------------------
      function solveTopLayer4() {
          for($i = 0; $i -le 4; $i++) {
              storeTopLayer
              $moveSet = storeTopLayerInt4
              Write-Host "$executor Moveset = $moveSet"
              $index = findMoveSet $moveSet
              Write-Host "$executor Index = $index"
              if ($index -ne 21) {
                  Write-Host "$executor Executing Moveset [ $index ]"
                  applyMoveSet $index
                  break
              } else {
                  Write-Host "$executor could not find a Moveset, rotating the top layer..."
                  $this.Move("U")
                  $this.printCube()
              }
              
          }
          $this.rotateCube()
      }
      
      function solvePLLMain() {
          storeTopLayer
          printTopLayer
          $moveSet = storeTopLayerInt1
          $index = findMoveSet $moveSet
          Write-Host "$executor Moveset = $moveSet"
          printTopLayerInt
          
          solveTopLayer1
          solveTopLayer2
          solveTopLayer3
          solveTopLayer4
          
          #Write-Host "$executor Found Index: $index"
          
          #applyMoveSet $index
          
          $checkTile = $this.Back[0][1]
          
          if($checkTile -ne "R") {
              Write-Host "$executor Correcting Top Layer..."
              switch($checkTile) {
                  "G" { $this.Move("UC") }
                  "B" { $this.Move("U") }
                  "O" { $this.Move("U"); $this.Move("U") }
              }
          }
          
          $this.printCube()
      }
      
      solvePLLMain
  }
  

} # end of class -------------------------------------------------------------------------------------------
$executor = "[ > CUBE-SOLVER < ]:"

function Line($title) {
    $totalWidth = 110         
    $borderChar = "="         
    $emptyBorderChar = " "

    $padding = [math]::floor(($totalWidth - 4 - $title.Length) / 2)
    $emptyBorderPadding = $emptyBorderChar * $padding
    $line = $borderChar * $totalWidth
    
    $titleLength = $title.Length

    if ($titleLength % 2 -eq 0) {
        $paddingRight = $padding - 2
    } else {
        $paddingRight = $padding - 1
    }

    $emptyBorderPaddingRight = $emptyBorderChar * $paddingRight

    Write-Host ""
    Write-Host "[$line]"
    Write-Host "|$emptyBorderPadding < $title > $emptyBorderPaddingRight|"
    Write-Host "[$line]"
    #Start-Sleep -Milliseconds 100
}



$cube = [RubiksCube]::new()

#$cube.writeCube()

$cube.fillSolved()
#$cube.fillDebug()

Line "Start"


Line "Scrambling the cube"
$cube.scrambleCube()
Line "Scrambled the cube."

Line "Printing the cube..."
$cube.printCube()
Line "Printed the cube."

Line "Checking the cube"
if ($cube.CheckCube()) {
    Write-Host "$executor The cube is correctly configured!"
} else {
    Write-Host "$executor An Error occured while validating the cube. Try Again."
    break
}
Line "Cube checked"

$cubeIsUnsolved = $true # temporary


Line "Finding stage..."
$stage = $cube.StageFinder()   # CHECK IMPACT OF $STAGE
Line "Stage found."

Line "Printing the cube..."
$cube.printCube()
Line "Printed the cube."


$stage = "SOLVED"

for($i = 0; $i -le 10; $i++) {
    if($stage -eq "SOLVED") {
        $cube.scrambleCube()
        
        $cube.SolveCross()  

        $cube.SolveCross()

        $cube.SolveF2L()

        $cube.SolveOLL()

        $cube.SolvePLL()
        Start-Sleep -Milliseconds 3000

        Line "Finding stage..."
        $stage = $cube.StageFinder()   # CHECK IMPACT OF $STAGE
        Line "Stage found."
    } else {
        Line "ERROR Stage = $stage"
        break
    }
    Start-Sleep -Milliseconds 1000
}

Write-Host "$executor The Cube is in Stage: $stage"

Line "Printing the cube..."
$cube.printCube()
Line "Printed the cube."

Line "End"

