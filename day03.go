package main

import (
	"fmt"
	"os"
)

func main() {
	file, err := os.Open("input03")
	if err != nil {
		fmt.Println("failed to open file!")
		return
	}
	defer file.Close()

	fileLen, _ := file.Seek(0, 2)
	file.Seek(0, 0)
	var buf = make([]byte, fileLen)

	_, err = file.Read(buf)
	if err != nil {
		fmt.Println("can't read")
		return
	}

	var width int
	for i, c := range buf {
		if c == '\n' {
			width = i
			break
		}
	}
	height := int(fileLen) / (width + 1)

	trees := countTrees(buf, width, height, 3, 1)
	fmt.Println("trees part 1: ", trees)

	trees2 := 1
	trees2 *= countTrees(buf, width, height, 1, 1)
	trees2 *= countTrees(buf, width, height, 3, 1)
	trees2 *= countTrees(buf, width, height, 5, 1)
	trees2 *= countTrees(buf, width, height, 7, 1)
	trees2 *= countTrees(buf, width, height, 1, 2)
	fmt.Println("trees part 2: ", trees2)
}

func countTrees(grid []byte, width int, height int, deltaX int, deltaY int) int {
	var treeCount int
	var x int
	var y int
	for y < height {
		cell := grid[x+y*(width+1)]
		if cell == '#' {
			treeCount++
		}
		x = (x + deltaX) % width
		y += deltaY
	}
	return treeCount
}
