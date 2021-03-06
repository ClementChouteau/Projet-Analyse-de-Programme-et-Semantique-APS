(** AST vers terme prolog *)
let rec topl_prog terme =
	match terme with
	|	Ast.Programme cmds ->
			"prog([" ^ (String.concat ", " (List.map topl_cmd cmds)) ^ "])"
and topl_cmd terme =
	match terme with
	|	Ast.CmdStat s -> topl_stat s
	|	Ast.CmdDec d -> topl_dec d
and topl_type terme =
	match terme with
	|	Ast.TypeInt -> "int"
	|	Ast.TypeBool -> "bool"
	|	Ast.TypeFonction (ts, t) ->
			"fleche(" ^ (topl_types ts ) ^ ", " ^ (topl_type t) ^ ")"
and topl_types terme =
	match terme with
	|	Ast.TypeTuple ts -> "[" ^ (String.concat ", " (List.map topl_type ts)) ^ "]"
and topl_arg terme =
	match terme with
	|	Ast.Arg (s, t) -> "(\"" ^ s ^ "\"," ^ (topl_type t) ^ ")"
and topl_dec terme =
	match terme with
	|	Ast.DecConst (id, t, e) ->
			"const(\"" ^ id ^ "\", " ^ (topl_type t) ^ ", " ^ (topl_expr e) ^ ")"
	|	Ast.DecFonction (id, t, args, e) ->
			"fun(\"" ^ id ^ "\", " ^ (topl_type t) ^ ", "
 		 	^ "[" ^ (String.concat ", " (List.map topl_arg args)) ^ "], "
			^ (topl_expr e) ^ ")"
	|	Ast.DecFonctionRec (id, t, args, e) ->
			"fun_rec(\"" ^ id ^ "\", " ^ (topl_type t) ^ ", "
			^ "[" ^ (String.concat ", " (List.map topl_arg args)) ^ "], "
			^ (topl_expr e) ^ ")"
and topl_stat terme =
	match terme with
	|	Ast.Echo e -> "echo(" ^ (topl_expr e) ^ ")"
and topl_expr terme = 
	match terme with
	|	Ast.Bool true -> "true"
	|	Ast.Bool false -> "false"
	|	Ast.Int i -> string_of_int i
	|	Ast.Identificateur id -> "ident(\"" ^ id ^ "\")"
	|	Ast.If (e1, e2, e3) ->
			"if(" ^ (topl_expr e1) ^ ", " ^ (topl_expr e2) ^ ", " ^ (topl_expr e3) ^ ")"
	|	Ast.Oprim (op, es) -> op ^ "(" ^ (String.concat ", " (List.map topl_expr es)) ^ ")"
	|	Ast.Abstraction (args, e) ->
			"abst([" ^ (String.concat ", " (List.map topl_arg args)) ^ "], " ^ (topl_expr e) ^ ")"
	|	Ast.Application (e, es) ->
			"app(" ^ (topl_expr e) ^ ", [" ^ (String.concat ", " (List.map topl_expr es)) ^ "])"
;;


let _ =
  try
    let lexbuf = Lexing.from_channel stdin in
    	try
    let p = Aps_yacc.prog Aps_lex.token lexbuf in
    	print_string (topl_prog p);
    	print_string ".";
    	with Parsing.Parse_error -> (print_int (lexbuf.Lexing.lex_curr_pos); print_string "\n")
  with | Aps_lex.Eof ->
    exit 0
    	
