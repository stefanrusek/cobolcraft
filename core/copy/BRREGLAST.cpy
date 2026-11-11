*> The last node a BR-REG call created or found (the node that holds the command of the form), EXTERNAL: a registration program that
*> must set more of the node (a redirect, a fork, a modifier: core/src/cmds-execute.cob) reads it after the call.
 01 BR-REG-LAST-STATE EXTERNAL.
    05 BR-REG-LAST-NODE      BINARY-LONG.
