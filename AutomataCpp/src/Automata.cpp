#include "Automata.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void Automata::_bind_methods() {
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

Automata::Automata() {
}

Automata::~Automata() {
    // Cleanup code.
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
