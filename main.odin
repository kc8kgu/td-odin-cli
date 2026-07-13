package main

import "core:fmt"
import "core:os"
import "core:encoding/json"

todo :: struct {
	id: int,
	done: bool,
	title: string
}

Error :: union {
    os.Error,
    json.Unmarshal_Error,
	json.Marshal_Error
}

main :: proc() {
	argc := len(os.args)
	argv := os.args

	err: Error = nil

	if argc == 1 {
		usage();
	} else if argc == 2 && argv[1] == "list" {
		_ = list_todos()
	} else if argc == 3 && argv[1] == "add" {
		_ = add_todos(argv[2])
	}

}

usage :: proc () {
	fmt.println("usage:  td <list|add|edit|done|delete|clear> <id> <title>")
}

load_todos :: proc (todos: ^[dynamic]todo ) -> Error {

	data, os_err := os.read_entire_file("./todo.json", context.allocator)
	if os_err != nil {
		fmt.eprintfln("os error: %s", os_err)

		return os_err
	}
	defer delete(data)

	json_err := json.unmarshal(data, todos)
	if json_err != nil {
		fmt.eprintfln("json_error: %s", json_err)
		return json_err
	}

	return nil
}

save_todos :: proc (todos: ^[dynamic]todo) -> Error {

	data, json_err := json.marshal(todos^)
	if json_err != nil {
		fmt.eprintfln("json error: %s", json_err)
		return json_err
	}
	defer delete(data)

	os_err := os.write_entire_file_from_bytes("todo.json", data)
	if os_err != nil {
		fmt.eprintfln("os error: %s", json_err)
		return os_err
	}

	return nil
}

list_todos :: proc() -> Error {

	todos : [dynamic] todo
	defer delete(todos)

	err := load_todos(&todos)
	if err != nil {
		return err
	}
	for td in todos {
		fmt.println(td)
	}

	return nil
}

add_todos :: proc (title: string) -> Error {

	todos : [dynamic] todo
	defer delete(todos)

	err := load_todos(&todos)
	if err != nil {
		return err
	}

	new_todo := todo{3, false, title}
	append(&todos, new_todo) 
	
	err = save_todos(&todos)
	if err != nil {
		return err
	}

	return nil
}

