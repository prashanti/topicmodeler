#include "stdafx.h"
#include "cokus2.c"

#include <stdio.h>
#include <math.h>

//#define savedir "G:\\sackler\\hmmlda150_1\\"

#define myrand() (double) (((unsigned long) randomMT()) / 4294967296.)

#define inputfilenm "..\\..\\..\\authors\\nih\\biganalysis_ldahmm_stream_1.txt" //"..\\..\\..\\authors\\nih\\NIMHhmmlda.txt"
#define savedir "..\\..\\..\\authors\\nih\\newhmm_50_10\\" //"..\\..\\..\\authors\\nih\\hmm100_30\\"

#define W      32605 //24085 // 21158 + 1    27064
#define D      22189 //3498  // 36999
#define NMAX   7200000 //3000000
#define KMAX   50 //100
#define SMAX   10 //50

#define BURNIN 10  //10
#define LAG    100 //100
#define NSAMP  10  //20
#define NRUNS  1   //1

#define NLOOPS BURNIN+LAG*NSAMP

#define ALPHA  0.1
#define BETA   0.01
#define GAMMA  0.1

int w[NMAX], z[NMAX], x[NMAX], d[NMAX];
double wp[W][KMAX];
double mp[W][SMAX];
double ztot[KMAX], mtot[SMAX], stot[SMAX][SMAX][SMAX];
int k, n;
double dp[D][KMAX];
double sp[SMAX][SMAX][SMAX][SMAX];
int first[NMAX], second[NMAX], third[NMAX];

void initialise(void);
void anderson(void);
void fileread(void);
void filewrite(void);

void initialise(void)
{
  int i,j,l,m;

  for (j = 0; j < KMAX; j++) {
    ztot[j] = 0;
    for (i = 0; i < W; i++) {
      wp[i][j] = 0;
    }
    for (i = 0; i < D; i++) {
      dp[i][j] = 0;
    }
  }
  for (j = 0; j < SMAX; j++) {
    mtot[j] = 0;
    for (i = 0; i < W; i++) {
      mp[i][j] = 0;
    }
    for (i = 0; i < SMAX; i++) {
      for (l =0; l < SMAX; l++) {
	stot[i][j][l] = 0;
	for (m = 0; m < SMAX; m++) {
	  sp[i][j][l][m] = 0;
	}
      }
    }
  }
}

void anderson(void)  //stochastic Anderson-style initialisation
{
  int i,j;
  double max, best, totprob, r;
  double probs[KMAX+SMAX];
  double wt, KALPHA, tot;
  int ind, temp, current, prev, preprev;

  current = 0;
  prev = 0;
  preprev = 0;
  first[0] = 0;
  second[0] = 0;
  third[0] = 0;
  KALPHA = (double) KMAX*ALPHA;
  for (i = 1; i < n; i++) {
    if (w[i] == -2) {
      sp[preprev][prev][current][0]++;
      first[i] = current;
      second[i] = prev;
      third[i] = preprev;
      preprev = 0;
      prev = 0;
      current = 0;
    } else {
      max = 0; best = 0; totprob = 0;
      x[i] = myrand()>0.5;
      for (j = 0; j < KMAX; j++) {
	probs[j] = dp[d[i]][j]+ALPHA;
	if (x[i]==1) {
	  probs[j] *= (wp[w[i]][j]+BETA)/(ztot[j]+W*BETA);
	}
	totprob += probs[j];
      }
      r = myrand()*totprob;
      max = probs[0];
      j = 0;
      while (r>max) {
	j++;
	max += probs[j];
      }
      z[i] = j;
      max = 0; best = 0;
      if (x[i]==0) {
	probs[1] = (wp[w[i]][j]+BETA)/(ztot[j]+W*BETA)
	  *(sp[preprev][prev][current][1]+GAMMA);
	totprob = probs[1];
	for (j = 2; j < SMAX; j++) {
	  probs[j] = (mp[w[i]][j]+BETA)/(mtot[j]+W*BETA)
	    *(sp[preprev][prev][current][j]+GAMMA);
	  totprob += probs[j];
	}
	r = myrand()*totprob;
	max = probs[1];
	j = 1;
	while (r>max) {
	  j++;
	  max += probs[j];
	}
	x[i] = j;
      }
      if (x[i] == 1) {
        wp[w[i]][z[i]]++;
	dp[d[i]][z[i]]++;
	ztot[z[i]]++;
      } else {
	mp[w[i]][x[i]]++;
      }
      mtot[x[i]]++;
      stot[prev][current][x[i]]++;
      sp[preprev][prev][current][x[i]]++;
      first[i] = current;
      second[i] = prev;
      third[i] = preprev;
      preprev = prev;
      prev = current;
      current = x[i];
    }
  }
  printf("Initial assignments: ");
  tot = 0;
  for (i = 0; i < KMAX; i++) {
    tot += ztot[i];
    printf(" %7.0lf", ztot[i]);
  }
  printf("\n");
  printf("LDA:  %10.0lf\n", tot);
  tot = 0;
  for (i = 0; i < SMAX; i++) {
    tot += mtot[i];
    printf(" %7.0lf", mtot[i]);
  }
  printf("\n");
  printf("HMM:  %10.0lf\n", tot);
    
}

void fileread(void) 
{
  int i,j;
  int wt;
  int count;
  FILE *fileptr;
  
/*

  -1 document boundary
  -2 sentence boundary?

*/

  if ((fileptr = fopen( inputfilenm , "r"))==NULL)
  {
     printf( "Could not open file\n");
	 exit(0);
  }

  //fileptr = fopen("isi_allwordstream.txt", "r"); 
  
  printf("File opened successfully...\n");
  
  // no need to read in number here !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //fscanf(fileptr, "%d", &wt);
  count = 0;
  n = 0;
  while (count < D-1) {
    fscanf(fileptr, "%d", &wt);
    if (wt==-1) 
	{
      count++;
	  printf( "Doc = %d n=%d\n" , count , n );
    } 
    else {
      w[n] = wt;
      d[n] = count;
      z[n] = 0;
      x[n] = 0;
      n++;

	  if (n == NMAX-1)
	  {
         printf( "NMAX not initialized high enough\n" );
	     exit(0);
	  }
    }
  }
  w[n] = -2;
  d[n] = count-1;
  z[n] = 0;
  x[n] = 0;
  n--;
  printf("Total cases: %10d\n Total documents: %10d\n", n, count);
}

main(int argc, char* argv[])
{
  int i,j,l,m,loop,run,rp,nzeros;
  int temp,ind,current,prev,preprev;
  double newprob, WBETA;
  double probs[KMAX+SMAX];
  double max, best, totprob, r, tot;
  int sampcount;
  FILE *fileptr;
  char filename[12];

  printf("Basic initialising...\n");

   // you can seed with any uint32, but the best are odds in 0..(2^32 - 1)
  seedMT(1);

  printf("Reading from file...\n");
  fileread();

  sampcount = 0;

  WBETA = (double) (W*BETA);

  probs[0] = 0;

  for (run = 0; run < NRUNS; run++) 
  {
	  printf("Initialising...\n");
	  initialise();
	  printf("Finding start state...\n");
	  anderson();
	  printf("Beginning burnin...\n");
	  for (loop = 0; loop < NLOOPS; loop++) 
	  {
		  current = 0;
		  prev = 0;
		  preprev = 0;
		  for (i = 1; i < n-2; i++) 
		  {
			  if (w[i] == -2) 
			  {
				  sp[third[i]][second[i]][first[i]][0]--;
				  sp[preprev][prev][current][0]++;
				  first[i] = current;
				  second[i] = prev;
				  third[i] = preprev;
				  current = 0;
				  prev = 0;
				  preprev = 0;
			  } else 
			  {
				  sp[third[i]][second[i]][first[i]][x[i]]--;
				  if (x[i] == 1) 
				  {
					  wp[w[i]][z[i]]--;
					  dp[d[i]][z[i]]--;
					  ztot[z[i]]--;
				  } else 
				  {
					  mp[w[i]][x[i]]--;
				  }
				  mtot[x[i]]--;
				  stot[second[i]][first[i]][x[i]]--;
				  max = 0; best = 0; totprob = 0;
				  for (j = 0; j < KMAX; j++) 
				  {
					  probs[j] = dp[d[i]][j]+ALPHA;
					  if (x[i] == 1) 
					  {
						  probs[j] *= (wp[w[i]][j]+BETA)/(ztot[j]+W*BETA);
					  }
					  totprob += probs[j];
				  }
				  r = myrand()*totprob;
				  max = probs[0];
				  j = 0;
				  while (r>max) 
				  {
					  j++;
					  max += probs[j];
				  }
				  z[i] = j;
				  probs[1]=(wp[w[i]][j]+BETA)/(ztot[j]+W*BETA)
					  *(sp[preprev][prev][current][1]+GAMMA)
					  *(sp[prev][current][1][x[i+1]]+GAMMA)/(stot[prev][current][1]+SMAX*GAMMA)
					  *(sp[current][1][x[i+1]][x[i+2]]+GAMMA)/(stot[current][1][x[i+1]]+SMAX*GAMMA)
					  *(sp[1][x[i+1]][x[i+2]][x[i+3]]+GAMMA)/(stot[1][x[i+1]][x[i+2]]+SMAX*GAMMA);
				  totprob = probs[1];
				  for (j = 2; j < SMAX; j++) 
				  {
					  probs[j]=(mp[w[i]][j]+BETA)/(mtot[j]+W*BETA)
						  *(sp[preprev][prev][current][j]+GAMMA)
						  *(sp[prev][current][j][x[i+1]]+GAMMA)/(stot[prev][current][j]+SMAX*GAMMA)
						  *(sp[current][j][x[i+1]][x[i+2]]+GAMMA)/(stot[current][j][x[i+1]]+SMAX*GAMMA)
						  *(sp[j][x[i+1]][x[i+2]][x[i+3]]+GAMMA)/(stot[j][x[i+1]][x[i+2]]+SMAX*GAMMA);
					  totprob += probs[j];
				  }
				  r = myrand()*totprob;
				  max = probs[1];
				  j = 1;
				  while (r>max) 
				  {
					  j++;
					  max += probs[j];
				  }
				  x[i] = j;
				  sp[preprev][prev][current][x[i]]++;
				  if (x[i] == 1) 
				  {
					  wp[w[i]][z[i]]++;
					  dp[d[i]][z[i]]++;
					  ztot[z[i]]++;
				  } else 
				  {
					  mp[w[i]][x[i]]++;
				  }
				  mtot[x[i]]++;
				  stot[prev][current][x[i]]++;
				  first[i] = current;
				  second[i] = prev;
				  third[i] = preprev;
				  preprev = prev;
				  prev = current;
				  current = x[i];
			  }
		  }
		  printf("%3d\n", loop);
		  tot = 0;
		  for (i = 0; i < KMAX; i++) 
		  {
			  tot += ztot[i];
			  //printf(" %7.0lf", ztot[i]);
		  }
		  //printf("\n");
		  //printf("LDA:  %10.0lf\n", tot);
		  tot = 0;
		  for (i = 0; i < SMAX; i++) 
		  {
			  tot += mtot[i];
			  //printf(" %7.0lf", mtot[i]);
		  }
		  //printf("\n");
		  //printf("HMM:  %10.0lf\n", tot-mtot[1]);
		  if ((loop>=BURNIN)&&((loop-BURNIN)%LAG==0)) 
		  {
			  sprintf(filename,"%swp%d.txt",savedir,sampcount);
			  fileptr = fopen(filename, "w");
			  fprintf( fileptr , "%d\n%d\n" , W , KMAX );
			  nzeros = 0;
			  for (rp=0; rp<2; rp++)
			  {
				  if (rp==1) fprintf( fileptr , "%d\n" , nzeros );
				  for (i = 0; i < W; i++) 
				  {
					  for (j = 0; j < KMAX; j++) 
					  {
						  if (wp[i][j]>0) 
						  {
							  nzeros++;
							  if (rp==1) fprintf(fileptr, "%d %d %5.0f\n", i , j , wp[i][j]);
						  }
					  }
				  }
			  }
			  fclose(fileptr);
			  
			  sprintf(filename,"%sdp%d.txt",savedir,sampcount);
			  fileptr = fopen(filename, "w");
			  fprintf( fileptr , "%d\n%d\n" , D , KMAX );
			  nzeros = 0;
			  for (rp=0; rp<2; rp++)
			  {
				  if (rp==1) fprintf( fileptr , "%d\n" , nzeros );
				  for (i = 0; i < D; i++) 
				  {
					  for (j = 0; j < KMAX; j++) 
					  {
						  if (dp[i][j]>0) 
						  {
							  nzeros++;
							  if (rp==1) fprintf(fileptr, "%d %d %5.0f\n", i , j , dp[i][j]);
						  }
					  }
				  }
			  }
			  fclose(fileptr);

			  sprintf(filename,"%smp%d.txt",savedir,sampcount);
			  fileptr = fopen(filename, "w");
			  fprintf( fileptr ,"%d\n%d\n" , W , SMAX );
			  nzeros = 0;
			  for (rp=0; rp<2; rp++)
			  {
				  if (rp==1) fprintf( fileptr , "%d\n" , nzeros );
				  
				  for (i = 0; i < W; i++) 
				  {
				      for (j = 0; j < SMAX; j++) 
					  {
					      if (mp[i][j]>0) 
						  {
							  nzeros++;
							  if (rp==1) fprintf(fileptr, "%d %d %5.0f\n", i , j , mp[i][j]);
						  }
					  }
				  }
			  }
			  fclose(fileptr);
			  
			  sprintf(filename,"%ssp%d.txt",savedir,sampcount);
			  fileptr = fopen(filename, "w");
			  nzeros =0;
			  for (rp=0; rp<2; rp++)
			  {
				  if (rp==1) fprintf( fileptr , "%d\n" , nzeros );

				  for (i = 0; i < SMAX; i++) 
				  {
					  for (j = 0; j < SMAX; j++) 
					  {
						  for (l = 0; l < SMAX; l++) 
						  {
							  for (m = 0; m < SMAX; m++) 
							  {
								  if (sp[i][j][l][m] > 0)
								  {
									  nzeros++;

									  if (rp==1) fprintf(fileptr, "%3d %3d %3d %3d %5.0f\n", i, j, l, m, sp[i][j][l][m]);
								  }
							  }
						  }
					  }
				  }
			  }
	
			  fclose(fileptr);
			  
			  /*
			  sprintf(filename,"%ssample%d.txt",savedir,sampcount);
			  fileptr = fopen(filename, "w");
			  fprintf( fileptr ,"%d\n" , n );
			  for (i = 0; i < n; i++) 
			  {
				  fprintf(fileptr, "%d %d %d %d\n", w[i] , d[i] , z[i], x[i] );
			  }
			  fclose(fileptr);
			  */

			  sampcount++;
			  
			  printf("Completed sample # %5d\n", sampcount);
		  } 
    }   
  }
}



