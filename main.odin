package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:encoding/json"

todo :: struct {
	id: int,
	done: bool,
	title: string
}

todos: [dynamic]todo

PATH : string = "./todo.json"


main :: proc() {

	argc := len(os.args)
	argv := os.args

	if argc == 1 {
		usage();
	} else if argc == 2 && argv[1] == "list" {
		list_todos()
	} else if argc == 3 && argv[1] == "add" {
		add_todo(argv[2])
	} else if argc == 4 && argv[1] == "edit" {
		edit_todo(argv[2], argv[3])
	} else if argc == 3 && argv[1] == "done" {
		done_todo(argv[2])
	} else if argc == 3 && argv[1] == "delete" {
		delete_todo(argv[2])
	} else if argc == 2 && argv[1] == "clear" {
		clear_todo()
	}
}

usage :: proc () {

	fmt.println("usage:  td <list|add|edit|done|delete|clear> <id> <title>")

}

load_todos :: proc () {

	if !os.exists(PATH) {
		file, os_err := os.create(PATH)
		if os_err != nil {
			fmt.eprintfln("os error: %s", os_err)
			os.exit(1)
		}
		os.close(file)
		return // dont try to load an empty file
	}

	data, os_err := os.read_entire_file("./todo.json", context.allocator)
	if os_err != nil {
		fmt.eprintfln("os error: %s", os_err)
		os.exit(1)
	}
	defer delete(data)

	json_err := json.unmarshal(data, &todos)
	if json_err != nil {
		fmt.eprintfln("json_error: %s", json_err)
		os.exit(1)
	}
}

save_todos :: proc () {

	data, json_err := json.marshal(todos)
	if json_err != nil {
		fmt.eprintfln("json error: %s", json_err)
		os.exit(1)
	}
	defer delete(data)

	os_err := os.write_entire_file_from_bytes("todo.json", data)
	if os_err != nil {
		fmt.eprintfln("os error: %s", json_err)
		os.exit(1)
	}
}

get_next_id :: proc() -> int {

	max_id: int = 0

	for td in todos {
		if td.id > max_id {
			max_id = td.id
		}
	}

	return 1 + max_id
}

list_todos :: proc() {

	load_todos()

	for td in todos {
		fmt.printf("%v, %v, %v \n", td.id, td.done, td.title)
	}
}

add_todo :: proc (title: string) {

	load_todos()

	next_id := get_next_id()
	new_todo := todo{next_id, false, title}

	append(&todos, new_todo) 
	
	save_todos()
}

edit_todo :: proc (idstr: string, title: string) {

	id, ok := strconv.parse_int(idstr)

	if !ok {
		return
	}

	load_todos()

	for &td in todos {
		if id == td.id {
			td.title = title
		}
	}

	save_todos()
}

done_todo :: proc (idstr: string) {

	id, ok := strconv.parse_int(idstr)

	if !ok {
		return
	}

	load_todos()

	for &td in todos {
		if id == td.id {
			td.done = !td.done
		}
	}

	save_todos()

}

delete_todo :: proc (idstr: string) {

	id, ok := strconv.parse_int(idstr)

	if !ok {
		return
	}

	load_todos()
	
	found: bool = false
	i: int = 0

	for td, idx in todos {
		if id == td.id {
			i = idx
			found = true
			break
		}
	}

	if found {
		ordered_remove_dynamic_array(&todos, i)
		save_todos()
	}
}

clear_todo :: proc () {
	os.remove(PATH)
}

