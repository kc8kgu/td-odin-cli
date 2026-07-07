package main

import "core:fmt"
import "core:os"

main :: proc() {
	
	argc := len(os.args)
	fmt.printf("argc:\t %d\n", argc)

	for arg, i in os.args {
		fmt.printf("arg[%d]:\t %s\n", i, arg)
	}

}
