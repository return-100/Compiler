int foo(int x) {
	return x++;
}
int main(){
	int a, b;
    while (a++) {
		b--;
	}
	println(b);
	foo(2);
}
