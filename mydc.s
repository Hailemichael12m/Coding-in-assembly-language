/*Name Hailemichael Molla
Student Number: 20190771
Assignment Number: Four*/
### --------------------------------------------------------------------
### mydc.s
###
### Desk Calculator (dc)
### --------------------------------------------------------------------

	.equ   ARRAYSIZE, 20
	.equ   EOF, -1
	.equ   TRUE, 1
	.equ   ZERO_OFFSET, 0
	.equ   NEG_FOUR_OFFSET, -4
	.equ   SECOND_ARG_OFFSET, 12
	.equ   FIRST_ARG_OFFSET, 8
.section ".rodata"

scanfFormat:
	.asciz "%s"
emptystack:
	.asciz "dc: stack empty\n"
printtop:
	.asciz "%d\n"
overflow_message:
	.asciz "dc: overflow happens\n"
div_by_zero:
	.asciz "dc: divide by zero\n"

### --------------------------------------------------------------------

        .section ".data"

### --------------------------------------------------------------------

        .section ".bss"
buffer:
        .skip  ARRAYSIZE


### --------------------------------------------------------------------

	.section ".text"

	## -------------------------------------------------------------
	## int main(void)
	## Runs desk calculator program.  Returns 0.
	## -------------------------------------------------------------

	.globl  main
	.type   main,@function
	.type power,@function

main:

	pushl   %ebp
	movl    %esp, %ebp

whileloop: ## while(1)

input:

	## dc number stack initialized. %esp = %ebp

	## scanf("%s", buffer)
	pushl	$buffer
	pushl	$scanfFormat
	call    scanf
	addl    $8, %esp

	## check if user input EOF
	cmp	$EOF, %eax
	je	quit

	## PSEUDO-CODE
	## /*
	##  * In this pseudo-code we are assuming that no local variables are created
	##  * in the _main_ process stack. In case you want to allocate space for local
	##  * variables, please remember to update logic for 'empty dc stack' condition
	##  * (lines 6, 15 and 20) accordingly.
	##  */
	##
	##1 while (1) {
	##2	if (scanf("%s", buffer) == EOF)
	##3		return 0;
	##4 	if (!isdigit(buffer[0])) {
	##5		if (buffer[0] == 'p') {
	##6			if (stack.peek() == NULL) { /* is %esp == %ebp? */
	##7				fprintf(stderr, "dc: stack empty\n");
	##8			} else {
	##9				printf("%d\n", (int)stack.top()); /* value is already pushed in the stack */
	##10			}
	##11		} else if (buffer[0] == 'q') {
	##12			goto quit;
	##13		} else if (buffer[0] == '+') {
	##14			int a, b;
	##15			if (stack.peek() == NULL) {
	##16				fprintf(stderr, "dc: stack empty\n");
	##17				continue;
	##18			}
	##19			a = (int)stack.pop();
	##20			if (stack.peek() == NULL) {
	##21				fprintf(stderr, "dc: stack empty\n");
	##22				stack.push(a); /* pushl some register value */
	##23				continue;
	##24			}
	##25			b = (int)stack.pop(); /* popl to some register */
	##26			res = a + b;
	##27 			stack.push(res);
	##28		} else if (buffer[0] == '-') {
	##29			/* ... */
	##30		} else if (buffer[0] == '^') {
	##31			/* ... powerfunc() ... */
	##32		} else if { /* ... and so on ... */
	##33 	} else { /* the first no. is a digit */
	##34		int no = atoi(buffer);
	##35		stack.push(no);	/* pushl some register value */
	##36	}
	##37 }

##check if the input's first char is not digit 
movl $0, %edx
movl $buffer, %edx
movzx ZERO_OFFSET(%edx), %ecx 
pushl %ecx
call isdigit
addl $4, %esp 
cmpl $0, %eax 
je check_p  
jmp digit

##if the input is digit
digit:  /*if(isdigit(buffer[0]))*/
	pushl $buffer
	call atoi
	addl $4, %esp
	pushl %eax
	jmp whileloop

#check if input is 'p'
check_p: /*if (buffer[0] == 'p')*/
	movb buffer, %al 
	cmpb $'p', %al
	je check_stack
	jmp check_quit

##check whether the stack is empty
check_stack: /*if (stack.peek() == NULL) { /* is %esp == %ebp? */
	cmpl %esp, %ebp
	je print_empty
	jmp print

##print out stack empty message to standard error
print_empty: /*fprintf(stderr, "dc: stack empty\n")*/
	pushl $emptystack
	pushl stderr
	call fprintf
	addl $8, %esp 
	jmp whileloop

##print when input is 'p' and stack is not empty
print:  /*printf("%d\n", (int)stack.top())*/
	pushl $printtop
	call printf
	addl $4, %esp 
	jmp whileloop

##check if input is 'q'
check_quit: /*if (buffer[0] == 'q')*/
	movb buffer, %al
	cmpb $'q', %al 
	je quit 
	jmp negative

##check if the input is negative, if so modify the buffer by 
##appending the negative sign so that atoi can give negative number
negative:  /*if (buffer[0] == '_')*/
	movl $buffer, %ecx
	movb ZERO_OFFSET(%ecx), %al
	cmpb $'_', %al
	jne check_plus

	movb $'-', ZERO_OFFSET(%ecx) 
	movl %ecx, %edx
	pushl %edx
	call atoi
	addl $4, %esp
	pushl %eax
	jmp whileloop

##check if input is '+' sign 
check_plus: /*if (buffer[0] == '+')*/
	movb buffer, %al
	cmpb $'+', %al
	je addition 
	jmp check_minus   

##addition operation after '+' is detected in the input
##check if the stack contains two operands
##print out error message to stderr in case of empty stack, 
## single operand or overflow
addition:  
	cmpl %esp, %ebp  /*if (stack.peek() == NULL) {*/
	je print_empty  /*fprintf(stderr, "dc: stack empty\n");*/
		
	popl %ecx 
	cmpl %esp, %ebp   /*if (stack.peek() == NULL) {*/
	je print_empty1   /*fprintf(stderr, "dc: stack empty\n");*/

	popl %edx
	addl %ecx, %edx 
	jo overflow
	pushl %edx
	jmp whileloop

##print out error message to stderr in case of overflow
overflow:
	pushl $overflow_message
	pushl stderr
	call fprintf
	addl $8, %esp 
	jmp quit

##prints out error message to stderr when there is only one operand
print_empty1:
	pushl $emptystack
	pushl stderr
	call fprintf
	addl $8, %esp
	pushl %ecx
	jmp whileloop

##check if input is '-' sign
check_minus: /*if (buffer[0] == '-')*/
	movb buffer, %al
	cmpb $'-', %al
	je subtraction
	jmp check_star

##compute subtraction
##check if the stack contains two operands
##print out error message to stderr in case of empty stack, 
## single operand or overflow
subtraction:
	cmpl %esp, %ebp  /*if (stack.peek() == NULL) {*/
	je print_empty    /*fprintf(stderr, "dc: stack empty\n");*/
	
	popl %ecx 
	cmpl %esp, %ebp
	je print_empty1

	popl %edx
	subl %ecx, %edx 
	jo overflow
	pushl %edx
	jmp whileloop

##check if input is '*'
check_star: /*if (buffer[0] == '*')*/
	movb buffer, %al
	cmpb $'*', %al
	je multiplication
	jmp check_slash

##compute multiplication
##check if the stack contains two operands
##print out error message to stderr in case of empty stack, 
## single operand or overflow
multiplication:
	cmpl %esp, %ebp  /*if (stack.peek() == NULL) {*/
	je print_empty    /*fprintf(stderr, "dc: stack empty\n");*/
	
	popl %ecx 
	cmpl %esp, %ebp
	je print_empty1

	popl %edx
	imull %ecx, %edx 
	jo overflow
	pushl %edx
	jmp whileloop


#check if input is '/'
check_slash:  /*if (buffer[0] == '/')*/
	movb buffer, %al
	cmpb $'/', %al
	je division
	jmp check_mod

##compute division 
##check if the stack contains two operands
##print out error message to stderr in case of empty stack, 
## single operand, overflow or division by zero
division:
	cmpl %esp, %ebp  /*if (stack.peek() == NULL) {*/
	je print_empty    /*fprintf(stderr, "dc: stack empty\n");*/
	
	popl %ecx
	cmpl $0, %ecx
	je division_by_zero

	cmpl %esp, %ebp
	je print_empty1

	popl %eax
	cdq
	idivl %ecx

	jo overflow
	pushl %eax
	jmp whileloop

##prints out error message to stderr in case of division by zero
division_by_zero:
	pushl $div_by_zero
	pushl stderr
	call fprintf
	addl $8, %esp
	jmp quit

##check if input is '%'
check_mod:  /*if (buffer[0] == '%')*/
	movb buffer, %al
	cmpb $'%', %al
	je modulo
	jmp check_power

##compute modulo operation
##check if the stack contains two operands
##print out error message to stderr in case of empty stack, 
## single operand, overflow or division by zero
modulo:
	cmpl %esp, %ebp  /*if (stack.peek() == NULL) {*/
	je print_empty   /*fprintf(stderr, "dc: stack empty\n");*/
	
	popl %ecx
	cmpl $0, %ecx
	je division_by_zero

	cmpl %esp, %ebp
	je print_empty1

	popl %eax
	cdq
	idivl %ecx

	jo overflow
	pushl %edx
	jmp whileloop

##check if input is '^'
check_power:    /*if (buffer[0] == '%')*/
	movb buffer, %al
	cmpb $'^', %al
	jne f_check 
	
	cmpl %esp, %ebp  /*if (stack.peek() == NULL) {*/
	je print_empty   /*fprintf(stderr, "dc: stack empty\n");*/

	popl %edx
	cmpl %esp, %ebp 
	je print_empty1
	pushl %edx

	call power  
	addl $8, %esp
	pushl %eax

	jmp whileloop


##definition of power function
power:   ## a^b
	pushl %ebp 
	movl %esp, %ebp 
	subl $4, %esp 
	movl SECOND_ARG_OFFSET(%ebp), %ebx    ## a to ebx
	movl FIRST_ARG_OFFSET(%ebp), %esi     ## b to esi
	movl %ebx, NEG_FOUR_OFFSET(%ebp)
	jmp compute_power

##compute the power operation
##consider zero power
##print out overflow messange in case of overflow
compute_power:
	cmpl $1, %esi
	je finish
	cmpl $0, %esi
	je zero_power
	movl NEG_FOUR_OFFSET(%ebp), %edi

	imull %ebx, %edi 
	jo overflow_power
	movl %edi, NEG_FOUR_OFFSET(%ebp)
	decl %esi
	jmp compute_power

##set zero power result to 1
zero_power:
	movl $1, %eax 
	movl %eax, NEG_FOUR_OFFSET(%ebp)
	jmp finish


##After printing error message, the operation should quit from the
##callee as well as caller. Thus, it should terminate without returning
##anything to the caller function.
overflow_power:
	pushl $overflow_message
	pushl stderr
	call fprintf
	addl $8, %esp 
	jmp quit_power

##quit from callee and then caller
quit_power:
	movl %ebp, %esp
	popl %ebp
	jmp quit

##return to caller function
finish:
	movl %ebp, %esp
	popl %ebp
	ret

##check if input is 'f'
f_check:  /*if (buffer[0] == 'f')*/
	movl $0, %ebx
	movl %esp, %ebx

	movb buffer, %al
	cmpb $'f', %al
	je f_operator
	jmp c_check


##compute f operation 
##print out the values in LIFO order until it gets stack frame
f_operator:
	cmpl %ebx, %ebp 
	je whileloop
	
	pushl (%ebx)
	pushl $printtop
	call printf
	addl $8, %esp 
	addl $4, %ebx 
	jmp f_operator

##check if input is 'c'
c_check:  /*if (buffer[0] == 'c')*/
	movb buffer, %al
	cmpb $'c', %al
	je clear
	jmp d_check

##clear the stack
clear:  
	cmpl %esp, %ebp 
	je whileloop
	addl $4, %esp 
	jmp clear

##check if input is 'd'
d_check:   /*if (buffer[0] == 'd')*/
	movb buffer, %al
	cmpb $'d', %al
	je duplicate
	jmp r_check

##duplicate the top most entry
duplicate:
	cmpl %esp, %ebp
	je print_empty

	popl %edx
	pushl %edx
	pushl %edx
	jmp whileloop

##check if input is 'r'
r_check:  /*if (buffer[0] == 'r')*/
	
	movb buffer, %al
	cmpb $'r', %al
	je reverse
	jmp whileloop

##swap the top two values in the stack
reverse:
	cmpl %esp, %ebp
	je print_empty

	popl %edx
	popl %ebx
	pushl %edx
	pushl %ebx
	jmp whileloop

quit:
	## return 0
	movl    $0, %eax
	movl    %ebp, %esp
	popl    %ebp
	ret
