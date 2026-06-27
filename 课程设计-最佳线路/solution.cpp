#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <algorithm>
#include <climits>
#include <iomanip>
#include <cstdio>
using namespace std;

const int INF = 1000000000;
const int MAXN = 105;

int N, K, W_cap, M;
int dist[MAXN][MAXN];
int nxt[MAXN][MAXN];

struct Package {
    int id;
    int weight;
    int dest;
};

void initData() {
    for (int i = 0; i < MAXN; i++) {
        for (int j = 0; j < MAXN; j++) {
            dist[i][j] = (i == j) ? 0 : INF;
            nxt[i][j] = -1;
        }
    }
}

void floyd() {
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++)
            if (dist[i][j] < INF && i != j)
                nxt[i][j] = j;
    
    for (int k = 0; k < N; k++)
        for (int i = 0; i < N; i++)
            for (int j = 0; j < N; j++)
                if (dist[i][k] < INF && dist[k][j] < INF &&
                    dist[i][k] + dist[k][j] < dist[i][j]) {
                    dist[i][j] = dist[i][k] + dist[k][j];
                    nxt[i][j] = nxt[i][k];
                }
}

vector<int> getPath(int u, int v) {
    vector<int> path;
    if (dist[u][v] >= INF) return path;
    int cur = u;
    path.push_back(cur);
    while (cur != v) {
        cur = nxt[cur][v];
        path.push_back(cur);
    }
    return path;
}

bool readData(const string& filename, vector<Package>& pkgs) {
    ifstream fin(filename);
    if (!fin.is_open()) return false;
    
    initData();
    pkgs.clear();
    
    fin >> N >> K >> W_cap >> M;
    
    string line;
    getline(fin, line);
    getline(fin, line);
    
    for (int i = 0; i < K; i++) {
        getline(fin, line);
        int a, b, c;
        sscanf_s(line.c_str(), "(%d,%d):%d", &a, &b, &c);
        dist[a][b] = dist[b][a] = c;
    }
    
    getline(fin, line);
    
    for (int i = 0; i < M; i++) {
        getline(fin, line);
        int x, y;
        sscanf_s(line.c_str(), "%d,%d", &x, &y);
        pkgs.push_back({i + 1, x, y});
    }
    
    fin.close();
    return true;
}

void stupidMethod(const vector<Package>& pkgs, int& outTotal) {
    cout << "\n========== 笨办法 ==========\n";
    int total = 0;
    for (const auto& p : pkgs) {
        int time = dist[0][p.dest] * 2;
        total += time;
        vector<int> path = getPath(0, p.dest);
        
        cout << "把重量为" << p.weight << "的" << p.id << "号包裹装车，";
        if (path.size() > 2) {
            cout << "途经";
            for (size_t j = 1; j < path.size() - 1; j++) {
                if (j > 1) cout << "、";
                cout << "S" << path[j];
            }
            cout << "送到S" << p.dest;
        } else {
            cout << "送到S" << p.dest;
        }
        cout << "，一去一回共计" << time << "个单位时间\n";
    }
    cout << "笨办法总共花费" << total << "个单位时间\n";
    outTotal = total;
}

void betterMethod(const vector<Package>& pkgs, int& outTotal) {
    cout << "\n========== 优化方案 ==========\n";
    int total = 0;
    int M_cnt = (int)pkgs.size();
    vector<bool> delivered(M_cnt, false);
    int deliveredCount = 0;
    int tripNum = 0;
    
    while (deliveredCount < M_cnt) {
        tripNum++;
        int cur = 0;
        int cap = W_cap;
        int tripTime = 0;
        vector<int> tripPkgs;
        vector<int> route;
        route.push_back(0);
        
        while (true) {
            int bestIdx = -1;
            int bestDist = INF;
            
            for (int i = 0; i < M_cnt; i++) {
                if (delivered[i]) continue;
                if (pkgs[i].weight > cap) continue;
                int d = dist[cur][pkgs[i].dest];
                if (d < bestDist) {
                    bestDist = d;
                    bestIdx = i;
                }
            }
            
            if (bestIdx == -1) break;
            
            vector<int> seg = getPath(cur, pkgs[bestIdx].dest);
            for (size_t j = 1; j < seg.size(); j++)
                route.push_back(seg[j]);
            
            tripTime += bestDist;
            cur = pkgs[bestIdx].dest;
            cap -= pkgs[bestIdx].weight;
            delivered[bestIdx] = true;
            deliveredCount++;
            tripPkgs.push_back(bestIdx);
        }
        
        vector<int> retSeg = getPath(cur, 0);
        for (size_t j = 1; j < retSeg.size(); j++)
            route.push_back(retSeg[j]);
        tripTime += dist[cur][0];
        total += tripTime;
        
        cout << "\n第" << tripNum << "趟：装载";
        for (size_t j = 0; j < tripPkgs.size(); j++) {
            if (j > 0) cout << "、";
            int idx = tripPkgs[j];
            cout << pkgs[idx].weight << "(" << pkgs[idx].id << "号->S" << pkgs[idx].dest << ")";
        }
        cout << "，载重" << (W_cap - cap) << "/" << W_cap;
        cout << "\n  路线：";
        for (size_t j = 0; j < route.size(); j++) {
            if (j > 0) cout << "->";
            cout << "S" << route[j];
        }
        cout << "\n  耗时：" << tripTime;
        if (tripPkgs.size() > 1)
            cout << "（单趟送" << tripPkgs.size() << "个包裹）";
        cout << "\n";
    }
    cout << "\n优化方案总共花费" << total << "个单位时间\n";
    outTotal = total;
}

int main() {
    system("chcp 65001 > nul");
    
    cout << "========================================\n";
    cout << "   最佳运送线路 -- 课程设计\n";
    cout << "========================================\n";
    
    cout << "\n" << left
         << setw(14) << "数据文件"
         << setw(10) << "地点数N"
         << setw(10) << "包裹数M"
         << setw(16) << "笨办法总耗时"
         << setw(16) << "优化方案总耗时"
         << setw(12) << "节约时间" << "\n";
    cout << string(78, '-') << "\n";
    
    int sumStupid = 0, sumBetter = 0;
    
    for (int fileIdx = 1; fileIdx <= 8; fileIdx++) {
        string filename = "Data" + to_string(fileIdx) + ".txt";
        vector<Package> pkgs;
        if (!readData(filename, pkgs)) {
            cout << "无法读取文件: " << filename << "\n";
            continue;
        }
        
        cout << "\n" << string(60, '=') << "\n";
        cout << "处理 " << filename << " (N=" << N << ", K=" << K
             << ", W=" << W_cap << ", M=" << M << ")\n";
        cout << string(60, '=');
        
        floyd();
        
        int stupidTotal = 0, betterTotal = 0;
        stupidMethod(pkgs, stupidTotal);
        betterMethod(pkgs, betterTotal);
        
        cout << "\n" << left
             << setw(14) << filename
             << setw(10) << N
             << setw(10) << M
             << setw(16) << stupidTotal
             << setw(16) << betterTotal
             << setw(12) << (stupidTotal - betterTotal) << "\n";
        
        sumStupid += stupidTotal;
        sumBetter += betterTotal;
    }
    
    cout << string(78, '-') << "\n";
    cout << left
         << setw(14) << "合计"
         << setw(10) << ""
         << setw(10) << ""
         << setw(16) << sumStupid
         << setw(16) << sumBetter
         << setw(12) << (sumStupid - sumBetter) << "\n";
    
    cout << "\n处理完毕。\n";
    return 0;
}
