/*
 Derived from Processing preprocessor code by Jakub Valtar and Florian Jenett.
 Copyright (c) 2021 Gagik Amaryan 
*/
parser grammar ProcessingParser;

import JavaParser;

options { tokenVocab=ProcessingLexer; }

// main entry point, select sketch type
processingSketch
    :   staticProcessingSketch
    |   activeProcessingSketch
    ;

// static mode, will run once (no function definitions)
staticProcessingSketch
	:	importDeclaration* blockStatement* importDeclaration* blockStatement* EOF
	;

// active mode, has function definitions
activeProcessingSketch
	:	importDeclaration* classBodyDeclaration* importDeclaration* classBodyDeclaration* EOF
	;

variableDeclaratorId
    :   warnTypeAsVariableName
    |   Identifier ('[' ']')*
    ;

// bug #93
// https://github.com/processing/processing/issues/93
// prevent from types being used as variable names
warnTypeAsVariableName
    :   primitiveType ('[' ']')* { 
            notifyErrorListeners("Type names are not allowed as variable names: "+$primitiveType.text); 
        }
    ;

// add support for converter functions int(), float(), ..
// Only the line with "functionWithPrimitiveTypeName" was added
// at a location before any "type" is being matched
expression
    :   primary
    |   expression '.' Identifier
    |   expression '.' 'this'
    |   expression '.' 'new' nonWildcardTypeArguments? innerCreator
    |   expression '.' 'super' superSuffix
    |   expression '.' explicitGenericInvocation
    |   expression '[' expression ']'
    |   apiFunction
    |   expression '(' expressionList? ')'
    |   'new' creator
    |   functionWithPrimitiveTypeName
    |   '(' typeType ')' expression
    |   expression ('++' | '--')
    |   ('+'|'-'|'++'|'--') expression
    |   ('~'|'!') expression
    |   expression ('*'|'/'|'%') expression
    |   expression ('+'|'-') expression
    |   expression ('<' '<' | '>' '>' '>' | '>' '>') expression
    |   expression ('<=' | '>=' | '>' | '<') expression
    |   expression 'instanceof' typeType
    |   expression ('==' | '!=') expression
    |   expression '&' expression
    |   expression '^' expression
    |   expression '|' expression
    |   expression '&&' expression
    |   expression '||' expression
    |   expression '?' expression ':' expression
    |   warnTypeAsVariableName
    |   <assoc=right> expression
        (   '='
        |   '+='
        |   '-='
        |   '*='
        |   '/='
        |   '&='
        |   '|='
        |   '^='
        |   '>>='
        |   '>>>='
        |   '<<='
        |   '%='
        )
        expression
    ;

// catch special API function calls that we are interessted in
apiFunction
    :   apiSizeFunction
    ;

apiSizeFunction
    : 'size' '(' expression ',' expression ( ',' expression )? ')'
    ;

// these are primitive type names plus "()"
// "color" is a special Processing primitive (== int)
functionWithPrimitiveTypeName
	:	(	'boolean'
		|	'byte'
		|	'char'
		|	'float'
		|	'int'
        |   'color'
		) '(' expressionList ')'
	;

// adding support for "color" primitive
primitiveType
	:	colorPrimitiveType
	|	javaPrimitiveType
	;

colorPrimitiveType
    :   'color'
    ;

// original Java.g4 primitiveType
javaPrimitiveType
    :   'boolean'
    |   'char'
    |   'byte'
    |   'short'
    |   'int'
    |   'long'
    |   'float'
    |   'double'
    ;

// added HexColorLiteral
literal
    :   hexColorLiteral
    |	IntegerLiteral
    |   DecimalfloatingPointLiteral
    |	FloatingPointLiteral
    |   CharacterLiteral
    |   StringLiteral
    |   BooleanLiteral
    |   'null'
    ;

// As parser rule so this produces a separate listener
// for us to alter its value.
hexColorLiteral
	:   HEX_COLOR_LITERAL	
	;

