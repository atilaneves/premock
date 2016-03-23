#ifndef PROD_H_
#define PROD_H_

#ifdef __cplusplus
extern "C" {
#endif

int prod_send(int fd);
int prod_zero();
int prod_one(int i);
int prod_two(int i, int j);

#ifdef __cplusplus
}
#endif


#endif // PROD_H_
