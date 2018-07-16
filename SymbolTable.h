#include <bits/stdc++.h>

using namespace std;

class tree_node
{
public:

    string code;
    string str;
    string type;
    int line_num;
    int ival;
    double dval;
    vector <tree_node*> vec;

    tree_node()
    {

    }
};

class func_node
{
public:

    string name;
    string type;
    vector <string> vec;
    vector <string> param;

    func_node()
    {

    }
};

class functionTable
{
public:

    int bucketSize, arr[10];
    vector <func_node*> def_func[10], dec_func[10];

    functionTable()
    {
        bucketSize = 10;
    }

    size_t get_hash(string str)
    {
        size_t fnv_prime = 1099511628211u;
        size_t hash = 14695981039346656037u;

        for (int i = 0; i < (int) str.size(); ++i)
             hash ^= str[i], hash *= fnv_prime;

        return hash % bucketSize;
    }

    func_node* is_declared(string name)
    {
        func_node *temp = NULL;

        int idx = get_hash(name);

        for (int i = 0; i < dec_func[idx].size(); ++i)
        {
            if (dec_func[idx][i]->name == name)
            {
                temp = dec_func[idx][i];
                break;
            }
        }

        return temp;
    }

    func_node* is_defined(string name)
    {
        func_node *temp = NULL;

        int idx = get_hash(name);

        for (int i = 0; i < def_func[idx].size(); ++i)
        {
            if (def_func[idx][i]->name == name)
            {
                temp = def_func[idx][i];
                break;
            }
        }

        return temp;
    }

    void insert_dec(func_node *ob)
    {
        int idx = get_hash(ob->name);
        dec_func[idx].push_back(ob);
    }

    void insert_def(func_node *ob)
    {
        int idx = get_hash(ob->name);
        def_func[idx].push_back(ob);
    }

    void remove(string name)
    {
        int idx = get_hash(name);

        for (int i = 0; i < def_func[idx].size(); ++i)
        {
            if (dec_func[idx][i]->name == name)
                dec_func[idx].erase(def_func[idx].begin() + i);
        }
    }
};

class symbolInfo
{
private:

    string name;
    string type;

public:

    int line_num;
    bool isarray;
    symbolInfo *next;
    string var_type;
    int num;

    symbolInfo()
    {
        next = NULL;
        isarray = false;
    }

    symbolInfo(string name, string type)
    {
        this->name = name;
        this->type = type;
        next = NULL;
        isarray = false;
    }

    string get_name()
    {
        return name;
    }

    string get_type()
    {
        return type;
    }

    void set_name(string name)
    {
        this->name = name;
    }

    void set_type(string type)
    {
        this->type = type;
    }
};

class scopeTable
{
private:

    int bucketSize, id;
    symbolInfo **arr;
    scopeTable *parent_scope;

public:

    scopeTable()
    {

    }

    scopeTable(int bucketSize, int id, scopeTable *parent)
    {
        parent_scope = parent;
        arr = new symbolInfo*[bucketSize];
        this->bucketSize = bucketSize, this->id = id + 1;

        for (int i = 0; i < bucketSize; ++i)
            arr[i] = 0;
    }

    size_t get_hash(string str)
    {
        size_t fnv_prime = 1099511628211u;
        size_t hash = 14695981039346656037u;

        for (int i = 0; i < (int) str.size(); ++i)
             hash ^= str[i], hash *= fnv_prime;

        return hash % bucketSize;
    }

    bool insert(string name, string type, string var_type, int scope_num)
    {
        symbolInfo *ob;
        int idx = get_hash(name);

        if (type == "array")
            ob = new symbolInfo(name, "ID");
        else
            ob = new symbolInfo(name, type);

        ob->var_type = var_type;
        ob->num = scope_num;

        if (type == "array")
            ob->isarray = true;

        if (arr[idx] == NULL)
            arr[idx] = ob;
        else if (lookup(name, idx, false))
            return false;
        else
            ob->next = arr[idx], arr[idx] = ob;

        return true;
    }

    symbolInfo* lookup(string name, int idx, bool mark)
    {
        int cnt = 0;
        symbolInfo *temp = arr[idx];

        while (temp)
        {
            if (temp->get_name() == name)
                break;

            temp = temp->next, ++cnt;
        }

        return temp;
    }

    bool remove(string name)
    {
        int idx = get_hash(name), cnt = 0;
        symbolInfo *temp = arr[idx], *pre = NULL;

        while (temp)
        {
            if (temp->get_name() == name)
            {
                if (pre == NULL)
                    arr[idx] = temp->next;
                else
                    pre->next = temp->next;

                return true;
            }

            pre = temp, temp = temp->next, ++cnt;
        }

        return false;
    }

    void print_scope_table(FILE *fp)
    {
        symbolInfo *temp;

        fprintf(fp, "ScopeTable # %d\n", id);

        for (int i = 0; i < bucketSize; ++i)
        {
            if (arr[i])
            {
                fprintf(fp, "%d -->  ", i);

                temp = arr[i];

                while (temp)
                    fprintf(fp, "< %s : %s> ", temp->get_name().c_str(), temp->get_type().c_str()), temp = temp->next;

                fprintf(fp, "\n");
            }
        }

        fprintf(fp, "\n");
    }

    scopeTable *get_parent_scope()
    {
        return parent_scope;
    }

    ~scopeTable()
    {
        parent_scope = 0;
        delete arr;
    }
};

class symbolTable
{
private:

    scopeTable *cur;
    int bucketSize, cnt;
    vector< scopeTable* > vec;

public:

    int scope_num;

    symbolTable()
    {

    }

    symbolTable(int bucketSize)
    {
        cnt = scope_num = 0, cur = NULL;
        this->bucketSize = bucketSize;
    }

    void enter_scope()
    {
        scopeTable *ob = new scopeTable(bucketSize, cnt, cur);
        vec.push_back(ob);
        ++cnt, ++scope_num;
        cur = ob;
    }

    void exit_scope()
    {
        if (cnt)
        {
            scopeTable *temp = cur;
            --cnt;
            cur = cur->get_parent_scope();
            vec.pop_back();
        }
    }

    bool insert(string name, string type, string var_type)
    {
        if (!cur)
            enter_scope();

        return cur->insert(name, type, var_type, scope_num);
    }

    bool remove(string name)
    {
        if (!cur)
            return false;

        return cur->remove(name);
    }

    symbolInfo *cur_look_up(string name)
    {
        symbolInfo *temp = NULL;

        temp = vec[cnt - 1]->lookup(name, vec[cnt - 1]->get_hash(name), true);

        if (temp)
            return temp;

        return NULL;
    }

    symbolInfo *look_up(string name)
    {
        symbolInfo *temp = NULL;

        for (int i = cnt - 1; i >= 0; --i)
        {
            temp = vec[i]->lookup(name, vec[i]->get_hash(name), true);

            if (temp)
                return temp;
        }

        return NULL;
    }

    void print_current_scope_table(FILE *fp)
    {
        cur->print_scope_table(fp);
    }

    void print_all_scope_table(FILE *fp)
    {
        for (int i = cnt - 1; i >= 0; --i)
        {
            vec[i]->print_scope_table(fp);

            if (i > 0)
                fprintf(fp, "\n\n");
        }
    }

    ~symbolTable()
    {
        cur = 0;
        delete cur;
        vec.clear();
    }
};
