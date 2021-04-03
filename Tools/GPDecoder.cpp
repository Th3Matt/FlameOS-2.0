#include <iostream>

int main(int argc, char** argv)
{
	char HexTable[] = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"};
	std::cout << "Segment: 0x";
	
	int a = argv[2], b = a>>3;
	for (int i=31;i>=0;i++)
	{
		std::cout << HexTable[(b>>(i*8))&0xF];
	}
	a &= 0x3;
	std::cout << ".\nAttributes: 0b";

	for (int i=2;i>=0;i++)
	{
		std::cout << HexTable[(a>>i)&0x1];
	}
	std::cout << ".\n";
}

