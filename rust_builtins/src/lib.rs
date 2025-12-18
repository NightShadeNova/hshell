use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::fs;

#[unsafe(no_mangle)]
pub extern "C" fn rustexe(argv: *const *const c_char, argc: i32) -> i32{

    let mut params: Vec<String> = Vec::new();
    unsafe{
        let num_args = argc as usize; //from_raw_parts wants usize for some reason
        let arg_ptrs = std::slice::from_raw_parts(argv, num_args); //making a rust list from c array

        for arg_ptr in arg_ptrs{
            if !arg_ptr.is_null(){
                let c_str = CStr::from_ptr(*arg_ptr);
                match c_str.to_str(){
                    Ok(s) => {
                        println!("Arg: {}", s);
                        params.push(s.to_owned()); //convert String to owned from borrowed(from &str to String)
                    }
                        Err(_) => { eprintln!("Error in argument")}
                }
            }
        }
    }
    let path = if params.len() > 1{
        &params[1]
    } else{
        "."
    };
    
    match fs::read_dir(path){//read_dir returns <ReadDir, Error> and ReadDir is an iterator over dir contents
        Ok(files) => {
            println!("\nFiles list:\n");
            for file in files{
                match file{

                    Ok(dir_entry) => {
                        println!("{}", dir_entry.file_name().to_string_lossy());//to_string_lossy ->`OsString` doesn't implement `std::fmt::Display`
                    }
                    Err(e) => {
                        eprintln!("Error: {}", e);
                    }
                }
            }
            0
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            -1
        }
    }
}