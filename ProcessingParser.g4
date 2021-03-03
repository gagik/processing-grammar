/*
 [The "BSD licence"]
 Copyright (c) 2013 Terence Parr, Sam Harwell
 Copyright (c) 2017 Ivan Kochurkin (upgrade to Java 8)
 Copyright (c) 2021 Gagik Amaryan (for Processing)
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
    |   decimalfloatingPointLiteral
    |	FloatingPointLiteral
    |   CharacterLiteral
    |   StringLiteral
    |   BooleanLiteral
    |   'null'
    ;

// As parser rule so this produces a separate listener
// for us to alter its value.
hexColorLiteral
	:	HexColorLiteral
	;

