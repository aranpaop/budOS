/***************************************************
*		版权声明
*
*	本操作系统名为：MINE
*	该操作系统未经授权不得以盈利或非盈利为目的进行开发，
*	只允许个人学习以及公开交流使用
*
*	代码最终所有权及解释权归田宇所有；
*
*	本模块作者：	田宇
*	EMail:		345538255@qq.com
*
*
***************************************************/

#ifndef __MEMORY_H__
#define __MEMORY_H__

#include "printk.h"
#include "lib.h"


struct Memory_E820_Formate
{
	unsigned int	address1;
	unsigned int	address2;
	unsigned int	length1;
	unsigned int	length2;
	unsigned int	type;
};

void init_memory();

#endif
