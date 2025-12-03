def getGrammarOperator(node):
    result = null
    mapGrammarOperatorsToNodes(node.parent.grammarBody,
        node.parent.children, (child, operator) =>
            if child == node:
                result = operator)
    return result

def repeaterFor(node):
    return getGrammarOperator(node).parentOperatorThat(p =>
        p.type == 'REPEAT')

# Return null if there is node is not a repeating structure,
# otherwise return the detected separator string or a space.
def separatorStringFor(node):
    repeater = repeaterFor(node)
    if not repeater: return null
    elif repeater.separator: return repeater.separator
    else: return " "

def deleteNode(editor, node):
    toDelete = [node]
    separator = separatorStringFor(node)
    if node.nextSibling?.text == separator:
        toDelete.push(node.nextSibling)
    elif node.previousSibling?.text == separator:
        toDelete.push(node.previousSibling)
    toDelete.sort(byCharacterIndex)
    editor.deleteRange(toDelete.first.range.start, toDelete.last.range.end)

def emptyListInsertIndex(parent, selector):
    lastSeenNode = null
    index = null
    # Traverse the grammar operators of parent. When a child node of parent corresponds
    # to that operator, invoke with both, otherwise invoke with child=null.
    mapGrammarOperatorsToNodes(parent.grammarBody, parent.children, (child, operator) =>
        lastSeenNode = child ?? lastSeenNode
        # When we have not yet found a start index and we find a repeat
        # operator that passes the user-provided operator and for which
        # no child node matches (i.e., an empty list), take the end index
        # of the last seen node or the start of the parent if this repeat
        # is at the start
        if index == null
        and operator.type == "REPEAT" and selector(operator) and child == null:
            start = lastSeenNode?.range.end ?? parent.range.start)
    return index

def insertNode(editor, parent, toInsert, index, selector = (operator) => true):
    lastValidChild = null
    for child in parent.children:
        repeater = repeaterFor(child)
        if repeater and selector(repeater):
            lastValidChild = child
            index--
            if index < 0:
                editor.insert(toInsert + separatorStringFor(child), child.range.start)
    # insert after all other children was requested
    if index > 0 and lastValidChild:
        editor.insert(separatorStringFor(child) + toInsert, lastValidChild.range.end)
    # no existing children found, empty or non-existing list
    elif lastValidChild == null:
        # find a valid empty list in the definition of the parent's grammar rule
        index = emptyListInsertIndex(parent)
        if index != null:
            editor.insert(toInsert, index)
        else:
            throw Error('No position for insert found')

def canParenthesizeNode(node):
    operator = getGrammarOperator(node)
    parentOperator = getGrammarOperator(node.parent)
    recursiveType = lastCommonAncestorOperator(operator, parentOperator)
    recursiveType.childOperatorThat(operator =>
        operator.type == 'SEQUENCE' and
        operator.children.first?.text == '(' and
        operator.children.last?.text == ')')

def replaceNode(editor, node, string):
    canParenthesize = canParenthesizeNode(node)
    targetRange = (node.range.start, node.range.start + string.length)
    editor.replaceRange(node.range.start, node.range.end, string)
    # check if our inserted node was accepted at the exact range or if
    # parsed as disjunct subtrees, in which case we retry with parentheses
    if canParenthesize and not editor.tree.getNodeAtRange(targetRange):
        editor.replaceRange(targetRange, '(' + string + ')')

