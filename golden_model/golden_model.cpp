#include <bitset>
#include <iomanip>
#include <iostream>

using namespace std;

const int N = 4;
int n, m, k;

float A[N][N], B[N][N], C[N][N];

union NMK {
  int8_t a[4];
  int i;
};

union FLOAT {
  float f;
  int i;
};

int main() {
  freopen("Sample2.txt", "r", stdin);
  freopen("golden_output2.txt", "w", stdout);

  NMK nmk = {};
  cin >> hex >> nmk.i;
  cout << setfill('0') << setw(8) << hex << nmk.i + 1 << endl;
  cin >> hex >> nmk.i;
  cout << setfill('0') << setw(8) << hex << nmk.i << endl;

  n = (int)nmk.a[3] & 255;
  m = (int)nmk.a[2] & 255;
  m = (int)nmk.a[1] & 255;
  k = (int)nmk.a[0] & 255;

  for (int i = 0; i < n; i++)
    for (int j = 0; j < m; j++) {
      FLOAT f = {};
      cin >> hex >> f.i;
      cout << setfill('0') << setw(8) << hex << f.i << endl;
      A[i][j] = f.f;
    }

  // for (int i = 0; i < N * N - n * m; i++) cin >> hex >> nmk.i;

  for (int i = 0; i < m; i++)
    for (int j = 0; j < k; j++) {
      FLOAT f = {};
      cin >> hex >> f.i;
      cout << setfill('0') << setw(8) << hex << f.i << endl;
      B[i][j] = f.f;
    }

  // for (int i = 0; i < N * N - m * k; i++) cin >> hex >> nmk.i;

  for (int x = 0; x < n; x++) {
    for (int y = 0; y < k; y++) {
      C[x][y] = 0;
      for (int i = 0; i < m; i++) 
        C[x][y] += A[x][i] * B[i][y];
    }
  }

  for (int i = 0; i < n; i++)
    for (int j = 0; j < k; j++) {
      FLOAT f = {};
      f.f = C[i][j];
      cout << setfill('0') << setw(8) << hex << f.i << endl;
    }

  return 0;
}