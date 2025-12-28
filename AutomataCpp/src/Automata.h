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
    unsigned int hash()const;
};

namespace std{
    template<>
    struct hash<rule>{
    inline size_t operator()(const rule& x)const{
        return x.hash();
    }
    };
}
struct arena{
    std::array<rule,1000> ruleArray;
    void push_back(rule element);
    void clear();
    int ptr=0;
    rule& operator[](int index){
        return ruleArray[index];
    }
    size_t size();
};
int unsafePow(unsigned int a,unsigned int b);
bool operator ==(const rule&,const rule&);


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
    void addRule(Array Rules,int result);
    void compileRuleset();
    void removeDuplicateRules();
    rule rotate(rule& r);
    arena getRules();
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
