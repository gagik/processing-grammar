/*
 Copyright (c) 2021 Gagik Amaryan
*/
lexer grammar ProcessingLexer;

import JavaLexer;

// add color literal notations for
// #ff5522
HexColorLiteral
	:	'#' HexDigit HexDigit HexDigit HexDigit HexDigit HexDigit
	;

// catch floating point numbers in a parser rule
DECIMAL_LITERAL:    ('0' | [1-9] (Digits? | '_'+ Digits)) [lL]?;

// copy from Java.g4 where is is just a fragment
HEX_FLOAT_LITERAL:  '0' [xX] (HexDigits '.'? | HexDigits? '.' HexDigits) [pP] [+-]? Digits [fFdD]?;