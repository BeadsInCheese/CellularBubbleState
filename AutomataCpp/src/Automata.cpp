#include "Automata.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void Automata::_bind_methods() {
    
    ClassDB::bind_method(D_METHOD("AutomataStep", "board"),&Automata::AutomataStep);
    ClassDB::bind_method(D_METHOD("printRules"),&Automata::printRules);



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



rule Automata::rotate( rule& r) {
    rule rotated; 
    

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
        
        // Copy other fields if any
        rotated.result = r.result;
    
        return rotated;
}

void Automata::printRules(){

    for(auto &i :rules){
        UtilityFunctions::print("Rule: ");
        for(int j=0;j<3; j++){
            UtilityFunctions::print(String::num(i.rows[j*3])+" , "+String::num(i.rows[j*3+1])+" , "+String::num(i.rows[j*3+2]));
        }

        UtilityFunctions::print("Result: "+String::num(i.result));
    }

}
std::vector<rule> Automata::getRules(){
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
            -1,2,0,
            -1,1,2};
    r6.result=0;
    rules.push_back( r6);
    rule r7;
    r7.rows={-1,-1,-1,
            2,0,-1,
            2,1,-1};
    r7.result=2;
    rules.push_back(r7);

    rule r8;
    r8.rows={-1,-1,-1,
            0,2,-1,
            2,1,-1};
    r8.result=0;
    rules.push_back( r8);
    int rl=rules.size();
    for (int j=0; j<rl;j++){
        rule nr;
        bool changed=false;
        for(int k=0; k<9; k++){
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
int Automata::evaluateTile(int xpos,int ypos,std::array<int,144> &board,Array &target){
        int pos=xpos+ypos*12;
        //push rule
        if(board[pos]==0){
            if(getTile(xpos+1,ypos,12,12,board)==2){
                if(getTile(xpos+2,ypos,12,12,board)==1){
                    target[pos]=2;
                    return 0;
                }
            }

            else if(getTile(xpos-1,ypos,12,12,board)==2){
                if(getTile(xpos-2,ypos,12,12,board)==1){
                    target[pos]=2;
                    return 0;
                }
            }
            else if(getTile(xpos,ypos+1,12,12,board)==2){
                if(getTile(xpos,ypos+2,12,12,board)==1){
                    target[pos]=2;

                    return 0;
                }
            }

            else if(getTile(xpos,ypos-1,12,12,board)==2){
                if(getTile(xpos,ypos-2,12,12,board)==1){
                    target[pos]=2;
                    return 0;
                }
            }

            else if(getTile(xpos+1,ypos,12,12,board)==4){
                if(getTile(xpos+2,ypos,12,12,board)==3){
                    target[pos]=4;
                    return 0;
                }
            }

            else if(getTile(xpos-1,ypos,12,12,board)==4){
                if(getTile(xpos-2,ypos,12,12,board)==3){
                    target[pos]=4;
                    return 0;
                }
            }
            else if(getTile(xpos,ypos+1,12,12,board)==4){
                if(getTile(xpos,ypos+2,12,12,board)==3){
                    target[pos]=4;
                    return 0;
                }
            }

            else if(getTile(xpos,ypos-1,12,12,board)==4){
                if(getTile(xpos,ypos-2,12,12,board)==3){
                    target[pos]=4;
                    return 0;
                }
            }
        }
        //birth Destroy 1
        else if(board[pos]==1){
            if(getTile(xpos+1,ypos,12,12,board)==0){
                if(getTile(xpos+2,ypos,12,12,board)==1){
                    target[pos]=0;
                    return 0;
                }
            }

             if(getTile(xpos-1,ypos,12,12,board)==0){
                if(getTile(xpos-2,ypos,12,12,board)==1){
                    target[pos]=0;
                    return 0;
                }
            }
             if(getTile(xpos,ypos+1,12,12,board)==0){
                if(getTile(xpos,ypos+2,12,12,board)==1){
                    target[pos]=0;
                    return 0;
                }
            }

             if(getTile(xpos,ypos-1,12,12,board)==0){
                if(getTile(xpos,ypos-2,12,12,board)==1){
                    target[pos]=0;
                    return 0;
                }
            }

            //birth destroy 2
        }else if(board[pos]==3) {
            if(getTile(xpos+1,ypos,12,12,board)==0){
                if(getTile(xpos+2,ypos,12,12,board)==3){
                    target[pos]=0;
                    return 0;
                }
            }

             if(getTile(xpos-1,ypos,12,12,board)==0){
                if(getTile(xpos-2,ypos,12,12,board)==3){
                    target[pos]=0;
                    return 0;
                }
            }
             if(getTile(xpos,ypos+1,12,12,board)==0){
                if(getTile(xpos,ypos+2,12,12,board)==3){
                    target[pos]=0;
                    return 0;
                }
            }

             if(getTile(xpos,ypos-1,12,12,board)==0){
                if(getTile(xpos,ypos-2,12,12,board)==3){
                    target[pos]=0;
                    return 0;
                }
            }

        }


        for(rule &j :rules){
            if(match3x3(xpos,ypos,board,j)){
               target[xpos+ypos*12]= j.result;
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
