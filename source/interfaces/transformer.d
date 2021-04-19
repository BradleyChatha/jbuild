module interfaces.transformer;

import execution;

abstract class Transformer
{
    abstract string transform(VariableValue value);
}