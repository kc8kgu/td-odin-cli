package main

import "core:fmt"
import "core:os"

todo :: struct {
	id: int,
	done: bool,
	title: string
}

main :: proc() {
	argc := len(os.args)
	argv := os.args

	if argc == 1 {
		usage();
	} else if argc == 2 && argv[1] == "list" {
		list_todos()
	}
}

usage :: proc () {
	fmt.println("usage:  td <list|add|edit|done|delete|clear")
}

list_todos :: proc () {

	todos : [dynamic] todo
	defer delete(todos)

	load_todos(&todos)

	for td in todos {
		fmt.println(td)
	}

}

load_todos :: proc (todos: ^[dynamic]todo ) {

	td : todo

	td = todo {1, false, "git init"}
	append_elem(todos,td)

	td = todo {1, false, "git add ."}
	append_elem(todos,td)

	td = todo {1, false, "git commit -m \"initial commit\""}
	append_elem(todos,td)

}