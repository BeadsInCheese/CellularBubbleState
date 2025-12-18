#ifndef AUTOMATA
#define AUTOMATA

#include <godot_cpp/classes/node2d.hpp>
#include <map>
#include <vector>

static constexpr int o = 5; //# shortcut for Any
static constexpr int t = -1;   //# shortcut for Tower
static constexpr int b = -2;   //# shortcut for Bubble

struct rule{
    size_t matrixSize=3;
    std::array<int,25> rows;
    int result;
};


namespace godot {

  
class Automata : public Node2D {
    GDCLASS(Automata, Node2D)

private:
    double time_passed;

   
    
protected:
    static void _bind_methods();

public:

    void printRules();
    void clearRuleset();
    void addRule(Array Rules);
    void compileRuleset();
    rule rotate(rule& r);
    std::vector<rule> getRules();
    int getTile(int xpos,int ypos,int xsize,int ysize,std::array<int,144> &board);
    bool matchMatrix(int posx,int posy,std::array<int,144> &board,rule &r);
    bool match3x3(int posx,int posy,std::array<int,144> &board,rule &r);
    bool match5x5(int posx,int posy,std::array<int,144> &board,rule &r);
    int evaluateTile(int xpos,int ypos,std::array<int,144> &board,Array &target);
    void runStep(std::array<int,144> &board,Array &target);
    Array AutomataStep(Array board);




    Automata();
    ~Automata();
     int checkRuleForPosStatic(int xpos,int ypos,Array board, Dictionary rules);
     int checkRuleStatic(Array matchGrid,int matchResult,int xpos,int ypos,int xmark,int ymark,Array board);
     int getGridTileTypeStatic(int xsize,int ysize,int xpos, int ypos,Array board);
     Array rotateGrid(Array grid);
     Array rotate2x2Grid(Array grid);
     Array rotate3x1Grid(Array grid);
     Array rotate1x3Grid(Array grid);
     Array rotate3x3Grid(Array grid);

     Array getMarkIndexes(Array matchGrid);
    
    void _process(double delta) override;
};
}



#endif
