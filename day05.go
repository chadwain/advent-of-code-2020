package main

import (
	"fmt"
	"os"
	"sort"
)

func main() {
	file, err := os.Open("input05")
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

	var list []int
	var line int
	for line < int(fileLen/11) {
		row, col := getRowAndColumn(buf[line*11 : line*11+10])
		var id = row*8 + col
		list = append(list, id)
		line++
	}

	sort.Ints(list)
	fmt.Println("highest id: %v", list[len(list)-1])

	for i, id := range list[:len(list)-1] {
		if list[i+1]-id == 2 {
			fmt.Println("your seat: %v", id+1)
		}
	}
}

func getRowAndColumn(str []byte) (row int, column int) {
	for i, c := range str[0:7] {
		if c == 'B' {
			row |= 1 << (6 - i)
		}
	}
	for i, c := range str[7:10] {
		if c == 'R' {
			column |= 1 << (2 - i)
		}
	}
	return
}
