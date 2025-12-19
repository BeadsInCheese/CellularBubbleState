#include "Automata.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void Automata::_bind_methods() {
    
    ClassDB::bind_method(D_METHOD("AutomataStep", "board"),&Automata::AutomataStep);
    ClassDB::bind_method(D_METHOD("printRules"),&Automata::printRules);

    ClassDB::bind_method(D_METHOD("clearRuleset"),&Automata::clearRuleset);
    ClassDB::bind_method(D_METHOD("addRule","pattern","result"),&Automata::addRule);
    ClassDB::bind_method(D_METHOD("compileRuleset"),&Automata::compileRuleset);



    ClassDB::bind_method(D_METHOD("checkRuleForPos", "xpos", "ypos", "board", "rules"), &Automata::checkRuleForPosStatic);
    ClassDB::bind_method(D_METHOD("checkRule", "matchGrid", "matchResult", "xpos", "ypos", "xmark", "ymark", "board"), &Automata::checkRuleStatic);
    ClassDB::bind_method(D_METHOD("getGridTileType", "xsize", "ysize", "xpos", "ypos", "board"), &Automata::getGridTileTypeStatic);
    ClassDB::bind_method(D_METHOD("rotateGrid", "grid"), &Automata::rotateGrid);
    ClassDB::bind_method(D_METHOD("rotate2x2Grid", "grid"), &Automata::rotate2x2Grid);
    ClassDB::bind_method(D_METHOD("rotate3x1Grid", "grid"), &Automata::rotate3x1Grid);
    ClassDB::bind_method(D_METHOD("rotate1x3Grid", "grid"), &Automata::rotate1x3Grid);
    ClassDB::bind_method(D_METHOD("rotate3x3Grid", "grid"), &Automata::rotate3x3Grid);
    ClassDB::bind_method(D_METHOD("getMarkIndexes", "matchGrid"), &Automata::getMarkIndexes);




}
std::vector<rule> rules;


Automata::~Automata() {
    // Cleanup code.
}
void godot::Automata::clearRuleset()
{
    rules.clear();
}
void godot::Automata::addRule(Array r,int result)
{
    if(r.size()!=3*3&&r.size()!=5*5){
        print_error("Error matrix must be eather size 3 or size 5");
        return;
    }
    rule rul;
    rul.matrixSize=sqrt(r.size());
    for(int i=0; i<r.size(); i++){
        if(r[i].get_type() == godot::Variant::Type::INT){
            rul.rows[i]=r[i];
        }else{
            print_error("Error incompatible matrix parameter "+r[i].get_type());
        return;
        }

    }
    rul.result=result;
    rules.emplace_back(rul);


}

void godot::Automata::compileRuleset()
{
    int rl=rules.size();
    for (int j=0; j<rl;j++){
        rule nr;
        bool changed=false;
        for(int k=0; k<25; k++){
            auto x=rules[j].rows[k];
            if(x==2){

                nr.rows[k]=4;
                changed=true;
            }
            else if(x==1){
                changed=true;
                nr.rows[k]=3;
            }
            else if(x==3){
                changed=true;
                nr.rows[k]=1;
            }
            else if(x==4){
                changed=true;
                nr.rows[k]=2;
            }else{
                nr.rows[k]=x;
            }
           
        }
        nr.result=rules[j].result;
        if(rules[j].result==1){
            nr.result=3;
        }
        else if(rules[j].result==2){
            nr.result=4;
        }else if(rules[j].result==3){
            nr.result=1;
        }else if(rules[j].result==4){
            nr.result=2;
        }else{
            nr.result=rules[j].result;
        }
        
        if(changed){
            nr.matrixSize=rules[j].matrixSize;
            rules.push_back(nr);
        }
    }
    rl=rules.size();
    
    for (int j=0; j<rl;j++){ 
        rule rot=rules[j];
        for(int i=0; i<4;i++){
            rot=rotate(rot);
            rules.push_back(rot);

        }
    }
    removeDuplicateRules();
    
}

void godot::Automata::removeDuplicateRules()
{

    std::unordered_map<rule,rule> table;

    for(auto& i : rules){
        print_line(i.hash());
        table[i]=i;
    }
    rules.clear();
    for(auto& i:table){
        rules.push_back(i.second);
    }


}

rule Automata::rotate(rule &r)
{
    rule rotated; 
    rotated.matrixSize=r.matrixSize;
        if(r.matrixSize==3){
             // Perform a 90-degree clockwise rotation:
            rotated.rows[0] = r.rows[6];
            rotated.rows[1] = r.rows[3];
            rotated.rows[2] = r.rows[0];
            
            rotated.rows[3] = r.rows[7];
            rotated.rows[4] = r.rows[4]; // Center remains the same
            rotated.rows[5] = r.rows[1];
            
            rotated.rows[6] = r.rows[8];
            rotated.rows[7] = r.rows[5];
            rotated.rows[8] = r.rows[2];
            
            rotated.result = r.result;
    
        
    }
    else{

        rotated.rows[0] = r.rows[20];
        rotated.rows[1] = r.rows[15];
        rotated.rows[2] = r.rows[10]; 
        rotated.rows[3] = r.rows[5];
        rotated.rows[4] = r.rows[0]; 
        rotated.rows[5] = r.rows[21];
            
        rotated.rows[6] = r.rows[16];
        rotated.rows[7] = r.rows[11];
        rotated.rows[8] = r.rows[6];
            
        rotated.rows[9] = r.rows[1];
        rotated.rows[10] = r.rows[22];
        rotated.rows[11] = r.rows[17];
            
        rotated.rows[12] = r.rows[12];
        rotated.rows[13] = r.rows[7]; 
        rotated.rows[14] = r.rows[2];
            
        rotated.rows[15] = r.rows[23];
        rotated.rows[16] = r.rows[18];
        rotated.rows[17] = r.rows[13];
            
        rotated.rows[18] = r.rows[8];
        rotated.rows[19] = r.rows[3];
        rotated.rows[20] = r.rows[24];
            
        rotated.rows[21] = r.rows[19];
        rotated.rows[22] = r.rows[14]; 
        rotated.rows[23] = r.rows[9];  
        rotated.rows[24] = r.rows[4];

        rotated.result = r.result;

    }
    return rotated;
}

void Automata::printRules(){
    UtilityFunctions::print(" rulecount "+String::num(rules.size()));
    for(auto &i :rules){
        UtilityFunctions::print("Rule: ");
        for(int j=0;j<i.matrixSize; j++){
            String text="";
            for(int k=0;k<i.matrixSize; k++){
               text+= String::num(i.rows[j*i.matrixSize+k])+" , ";
            }  
            UtilityFunctions::print(text);
        }

        UtilityFunctions::print("Result: "+String::num(i.result));
    }

}



std::vector<rule> Automata::getRules()
{
    std::vector<rule> rules;

    rule r;
    r.rows={-1,2,-1,
            2,4,-1,
            -1,-1,-1};
    r.result=2;
    rules.push_back(r);
    rule r2;
    r2.rows={2,2,2,
            -1,0,-1,
            -1,-1,-1};
    r2.result=2;
    rules.push_back(r2);
    
    rule r3;
    r3.rows={-1,-1,-1,
            -1,0,1,
            -1,1,2};
    r3.result=2;
    rules.push_back(r3);

    rule r4;
    r4.rows={-1,1,-1,
            -1,0,-1,
            -1,1,-1};
    r4.result=2;
    rules.push_back(r4);

    
    rule r5;
    r5.rows={-1,-1,-1,
            -1,0,2,
            -1,1,2};
    r5.result=2;
    rules.push_back(r5);

    rule r6;
    r6.rows={-1,-1,-1,
            0,2,-1,
            1,2,-1};
    r6.result=0;
    rules.push_back(r6);
    rule r7;
    r7.rows={-1,-1,-1,
            2,0,-1,
            2,1,-1};
    r7.result=2;
    rules.push_back(r7);

    rule r8;
    r8.rows={-1,-1,-1,
            -1,2,0,
            -1,2,1};
    rules.push_back(r8);
    rule r9;
    r9.rows={
            -1,-1,-1,-1,-1,
            -1,-1,-1,-1,-1,
            1,2,0,-1,-1,
            -1,-1,-1,-1,-1,
            -1,-1,-1,-1,-1
        }
        ;
        r9.matrixSize=5;
    r9.result=2;
    
    rules.push_back(r9);

    rule r10;
    r10.rows={
            -1,-1,-1,-1,-1,
            -1,-1,-1,-1,-1,
            1,0,1,-1,-1,
            -1,-1,-1,-1,-1,
            -1,-1,-1,-1,-1
        }
        ;
        r10.matrixSize=5;
    r10.result=0;
    
    rules.push_back(r10);

    int rl=rules.size();
    for (int j=0; j<rl;j++){
        rule nr;
        bool changed=false;
        for(int k=0; k<25; k++){
            auto x=rules[j].rows[k];
            if(x==2){

                nr.rows[k]=4;
                changed=true;
            }
            else if(x==1){
                changed=true;
                nr.rows[k]=3;
            }
            else if(x==3){
                changed=true;
                nr.rows[k]=1;
            }
            else if(x==4){
                changed=true;
                nr.rows[k]=2;
            }else{
                nr.rows[k]=x;
            }
           
        }
        nr.result=rules[j].result;
        if(rules[j].result==1){
            nr.result=3;
        }
        else if(rules[j].result==2){
            nr.result=4;
        }else if(rules[j].result==3){
            nr.result=1;
        }else if(rules[j].result==4){
            nr.result=2;
        }else{
            nr.result=rules[j].result;
        }
        
        if(changed){
            nr.matrixSize=rules[j].matrixSize;
            rules.push_back(nr);
        }
    }
    rl=rules.size();
    
    for (int j=0; j<rl;j++){ 
        rule rot=rules[j];
        for(int i=0; i<4;i++){
            rot=rotate(rot);
            rules.push_back(rot);

        }
    }
    return rules;
}
Automata::Automata() {
    auto r=getRules();
    UtilityFunctions::print("Automata rules initiated rulecount "+String::num(r.size()));
    rules=r;
}
int Automata::getTile(int xpos,int ypos,int xsize,int ysize,std::array<int,144> &board){
    if (xpos < 0 || ypos < 0 || xpos >= xsize || ypos >= ysize) {
        return 5;
    }
    return board[xpos + ypos * ysize];
}

bool Automata::match3x3(int posx,int posy,std::array<int,144> &board,rule &r){
    
    for(int i=0; i<3;i++){
        for(int j=0; j<3;j++){
            
            int a=r.rows[i+j*3];
            int b=getTile(posx-1+i,posy+j-1,12,12,board);
            
            if(a==-1){
                continue;
            }
            if(b!=a){
                return false;
            }
            
        }
        
        
    }
    return true;

    
}
bool godot::Automata::match5x5(int posx, int posy, std::array<int, 144> &board, rule &r)
{
    for(int i=0; i<5;i++){
        for(int j=0; j<5;j++){
            
            int a=r.rows[i+j*5];
            int b=getTile(posx-2+i,posy+j-2,12,12,board);
            
            if(a==-1){
                continue;
            }
            if(b!=a){
                return false;
            }
            
        }
        
        
    }
    return true;
}
bool godot::Automata::matchMatrix(int posx, int posy, std::array<int, 144> &board, rule &r){
    if(r.matrixSize==3){
        return match3x3( posx,  posy,  board, r);
    }else{
        return match5x5( posx,  posy,  board, r);
    }

}
int Automata::evaluateTile(int xpos, int ypos, std::array<int, 144> &board, Array &target)
{
    for (rule &j : rules)
    {
        if (matchMatrix(xpos, ypos, board, j))
        {
            target[xpos + ypos * 12] = j.result;
            break;
        }
    }

    

    return 0;
}
void Automata::runStep(std::array<int,144> &board,Array& target){
    for(int i=0; i< board.size(); i++){
        int x=i%12;
        int y=i/12;

        evaluateTile(x,y,board,target);
    }

}
Array Automata::AutomataStep(Array board){
    std::array<int, 144> b;
    for(int i=0; i<144; i++){
        b[i]=int(board[i]);

    }

    runStep(b,board);

    return board;

}





int Automata::checkRuleForPosStatic(int xpos, int ypos, Array board,Dictionary rules) {
    for (int idx = 0; idx < rules.size(); ++idx) {
        Array matchGrid = rules.keys()[idx];
        Array grid = matchGrid;
        Array marks = getMarkIndexes(matchGrid);

        for (int rot = 0; rot < 4; ++rot) {
            Array mark = marks[rot];
            int result = checkRuleStatic(grid, rules[rules.keys()[idx]], xpos, ypos, mark[0], mark[1], board);
            if (result != -1) {
                return result;
            }
            if (rot < 3) {
                grid = rotateGrid(grid);
            }
        }
    }
    return -1;
}

int Automata::checkRuleStatic(Array matchGrid, int matchResult, int xpos, int ypos, int xmark, int ymark, Array board) {
    int matchPlayer = 0;
    int sizex = ((Array)matchGrid[0]).size();
    int sizey = matchGrid.size();
    for (int j = 0; j < sizex; ++j) {
        for (int i = 0; i < sizey; ++i) {
            int matchRef = ((Array)matchGrid[i])[j];

            if (matchRef == 5) {
                continue;
            }
            int tile = getGridTileTypeStatic(12, 12, i + xpos - xmark, j + ypos - ymark, board);

            if (matchRef == t) {
                if ((tile != 1 && tile != 3) || (matchPlayer == 1 && tile == 3) || (matchPlayer == 2 && tile == 1)) {
                    return -1;
                }
                matchPlayer = (tile == 1) ? 1 : 2;
            } else if (matchRef == b) {
                if ((tile != 2 && tile != 4) || (matchPlayer == 1 && tile == 4) || (matchPlayer == 2 && tile == 2)) {
                    return -1;
                }
                matchPlayer = (tile == 2) ? 1 : 2;
            } else if (matchRef != tile) {
                return -1;
            }
        }
    }
    if (matchResult == b) {
        return (matchPlayer == 1) ? 2 : 4;
    }
    if (matchResult == t) {
        return (matchPlayer == 1) ? 1 : 3;
    }
    return matchResult;
}

int Automata::getGridTileTypeStatic(int xsize, int ysize, int xpos, int ypos, Array board) {
    if (xpos < 0 || ypos < 0 || xpos >= xsize || ypos >= ysize) {
        return 5;
    }
    return board[xpos + ypos * ysize];
}

Array Automata::rotateGrid(Array grid) {
    int size = grid.size();
    if (size == 2) {
        return rotate2x2Grid(grid);
    } else if (size == 1) {
        return rotate1x3Grid(grid);
    } else if (size == 3 && ((Array)grid[0]).size() == 1) {
        return rotate3x1Grid(grid);
    } else {
        return rotate3x3Grid(grid);
    }
}

Array Automata::rotate2x2Grid(Array grid) {
    Array rotated_grid;
    rotated_grid.append(Array::make(((Array)grid[0])[1], ((Array)grid[1])[1]));
    rotated_grid.append(Array::make(((Array)grid[0])[0], ((Array)grid[1])[0]));
    return rotated_grid;
}

Array Automata::rotate3x1Grid(Array grid) {
    Array inner_array;
    inner_array.append(((Array)grid[2])[0]);
    inner_array.append(((Array)grid[1])[0]);
    inner_array.append(((Array)grid[0])[0]);
    Array outer_array;
    outer_array.append(inner_array);
    return outer_array;
}

Array Automata::rotate1x3Grid(Array grid) {
    return Array::make(Array::make(((Array)grid[0])[0]), Array::make(((Array)grid[0])[1]), Array::make(((Array)grid[0])[2]));
}

Array Automata::rotate3x3Grid(Array grid) {
    Array result;
    for (int i = 0; i < 3; ++i) {
        result.append(Array());
        for (int j = 0; j < 3; ++j) {
            ((Array)result[i]).append(((Array)grid[j])[2 - i]);
        }
    }
    return result;
}

Array Automata::getMarkIndexes(Array matchGrid) {
    int size = matchGrid.size();
    if (size == 2) {
        return Array::make(Array::make(0, 0), Array::make(1, 0), Array::make(1, 1), Array::make(0, 1));
    } else if (size == 1) {
        return Array::make(Array::make(0, 0), Array::make(0, 0), Array::make(0, 2), Array::make(2, 0));
    } else {
        return Array::make(Array::make(1, 1), Array::make(1, 1), Array::make(1, 1), Array::make(1, 1));
    }
}

void Automata::_process(double delta) {
}

unsigned int rule::hash()const
{
    unsigned int h=0;
    for(int i=0; i<matrixSize; i++){
        h+=unsafePow(6,i)*(rows[i]+2);
    }
    return h;
}
int unsafePow(unsigned int a,unsigned int b){
    if(b==0){
        return 1;
    }
    if(b%2==1){
        return a*unsafePow(a,b-1);
    }
    int half=b/2;
    return unsafePow(a,half)*unsafePow(a,half);

}

bool operator==(const rule& a, const rule& b) {
    if (a.matrixSize != b.matrixSize) return false;
    for (int i = 0; i < a.matrixSize * a.matrixSize; i++) {
        if (a.rows[i] != b.rows[i]) return false;
    }
    return true;
}