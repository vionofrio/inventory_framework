"""Minimal Pawn top-level parser used for refactoring + static checks."""
import re, os

def read(path):
    raw = open(path, 'rb').read()
    for enc in ('utf-8', 'cp1252', 'latin-1'):
        try:
            return raw.decode(enc)
        except UnicodeDecodeError:
            pass

def strip_code(s):
    """Return s with comments and string/char literal contents blanked (same length, newlines kept)."""
    out = []; i = 0; n = len(s)
    while i < n:
        c = s[i]
        if s.startswith('//', i):
            j = s.find('\n', i)
            j = n if j < 0 else j
            out.append(' ' * (j - i)); i = j
        elif s.startswith('/*', i):
            j = s.find('*/', i + 2)
            j = n if j < 0 else j + 2
            out.append(''.join('\n' if ch == '\n' else ' ' for ch in s[i:j])); i = j
        elif c == '"':
            j = i + 1
            while j < n and s[j] != '"':
                if s[j] == '\\': j += 1
                j += 1
            j = min(j + 1, n)
            out.append('"' + ''.join('\n' if ch == '\n' else ' ' for ch in s[i+1:j-1]) + '"'); i = j
        elif c == "'":
            j = i + 1
            while j < n and s[j] != "'":
                if s[j] == '\\': j += 1
                j += 1
            j = min(j + 1, n)
            out.append("'" + ' ' * (j - i - 2) + "'"); i = j
        else:
            out.append(c); i += 1
    return ''.join(out)

FUNC_RE = re.compile(r'^(?P<static>static\s+)?(?P<kw>stock|public|forward|native)\s+(?P<ret>(?:[A-Za-z_]\w*(?:<\w+>)?:)*)\s*(?P<name>[A-Za-z_]\w*)\s*\(')
PLAIN_FUNC_RE = re.compile(r'^(?P<static>static\s+)?(?P<ret>(?:[A-Za-z_]\w*(?:<\w+>)?:)*)\s*(?P<name>[A-Za-z_]\w*)\s*\(')

class Item:
    __slots__ = ('kind', 'name', 'text', 'start', 'end', 'static', 'kw', 'is_def', 'arity', 'lead', 'sig')
    def __repr__(self):
        return f'<{self.kind} {self.name}>'

def count_params(sig):
    # sig: text between the outermost parentheses
    sig = sig.strip()
    if not sig or sig == 'void': return 0
    depth = 0; n = 1
    for ch in sig:
        if ch in '([{<': depth += 1
        elif ch in ')]}>': depth -= 1
        elif ch == ',' and depth == 0: n += 1
    return n

def parse_items(text):
    """Split a file into top-level items. Returns list of Item. Leading comments/blank lines attach to the next item
    ('lead' is kept inside text)."""
    lines = text.split('\n')
    code = strip_code(text).split('\n')
    items = []
    i = 0; n = len(lines)
    pending_start = 0  # first line of the pending lead block
    depth = 0
    def flush_blank_or_comment(idx):
        return code[idx].strip() == ''
    while i < n:
        c = code[i]
        st = c.strip()
        if st == '':
            # blank (or comment-only) line: lead block continues only through comments; a blank resets lead when no comment follows
            i += 1
            continue
        # top-level statement start at i
        start = i
        # find the extent
        if st.startswith('#'):
            # preprocessor: handle line continuation
            j = i
            while code[j].rstrip().endswith('\\') and j + 1 < n: j += 1
            kind = 'pp'
            m = re.match(r'#\s*(\w+)\s*(\w+)?', st)
            name = (m.group(1) + ' ' + (m.group(2) or '')).strip() if m else st
            end = j
        else:
            # accumulate until depth returns to 0 at a ';' or '}' that closes a body
            j = i; d = 0; seen_brace = False; ended = False
            while j < n and not ended:
                for k, ch in enumerate(code[j]):
                    if ch in '{':
                        d += 1; seen_brace = True
                    elif ch == '}':
                        d -= 1
                        if d == 0 and seen_brace:
                            ended = True
                    elif ch == ';' and d == 0 and not seen_brace:
                        ended = True
                    if ended: break
                if ended: break
                # function def without body-brace on same line: header ends and next line '{'
                j += 1
            end = min(j, n - 1)
            kind = 'other'; name = None
            m = FUNC_RE.match(st)
            if m is None:
                m2 = PLAIN_FUNC_RE.match(st)
                m = m2 if (m2 and m2.group('name') not in ('new', 'enum', 'const', 'static', 'if', 'for', 'while', 'switch', 'return') ) else None
            if m:
                kind = 'func'; name = m.group('name')
            else:
                m3 = re.match(r'^(?:static\s+)?(?:new|const|enum)\b\s*(\w+)?', st)
                if m3:
                    kind = 'decl'
                    name = (st.split()[0] if st.startswith(('new', 'const', 'enum')) else st.split()[1]) + ' ' + (m3.group(1) or '')
                    name = name.strip()
        # attach lead comments: walk backwards over comment-only lines (code line blank but source line nonblank)
        s0 = start
        prev_end = items[-1].end if items else -1
        k = start - 1
        while k > prev_end:
            if lines[k].strip() != '' and code[k].strip() == '':      # comment-only line
                s0 = k; k -= 1
            elif lines[k].strip() == '':                              # blank: continue only if a comment block sits above
                j = k
                while j > prev_end and lines[j].strip() == '': j -= 1
                if j > prev_end and lines[j].strip() != '' and code[j].strip() == '':
                    k = j
                else:
                    break
            else:
                break
        it = Item()
        it.kind = kind; it.name = name; it.start = s0; it.end = end
        it.text = '\n'.join(lines[s0:end + 1])
        it.lead = '\n'.join(lines[s0:start])
        it.static = False; it.kw = None; it.is_def = False; it.arity = None; it.sig = None
        if kind == 'func':
            it.static = bool(m.group('static')); it.kw = m.groupdict().get('kw')
            body = '\n'.join(code[start:end + 1])
            # find param list
            p = body.find('(', body.find(name))
            d = 0; q = p
            while q < len(body):
                if body[q] == '(': d += 1
                elif body[q] == ')':
                    d -= 1
                    if d == 0: break
                q += 1
            it.sig = body[p + 1:q]
            it.arity = count_params(it.sig)
            tail = body[q + 1:].lstrip()
            it.is_def = tail.startswith('{')
            if it.kw == 'forward' or tail.startswith(';'):
                it.is_def = False
        items.append(it)
        i = end + 1
    return items

if __name__ == '__main__':
    import sys
    for it in parse_items(read(sys.argv[1])):
        print(it.start + 1, it.end + 1, it.kind, it.name, 'DEF' if it.is_def else '', 'static' if it.static else '')
