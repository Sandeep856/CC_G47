#def DEBUG 10
let x=5;
#ifdef DEBUG
dbg x;
#endif

let b=50;
let c=10;
let a=1;
a = c+b;
dbg a;
let d=5;
//bruh hey
/*
Multiline comment
*/
let e=2;
let f=3;
let g=11;
let h=13;
let i=29;
let j=80;
a=j;
a = a ? b: c ? d : e ? f : g ? h : i;
dbg a;