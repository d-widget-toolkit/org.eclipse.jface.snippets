/*******************************************************************************
 * Copyright (c) 2006 Tom Schindl and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Tom Schindl - initial API and implementation
 * Port to the D programming language:
 *     yidabu at gmail dot com  ( D China http://www.d-programming-language-china.org/ )
 *******************************************************************************/

module snippets.viewers.Snippet043NoColumnTreeViewerKeyboardEditing;

import dwtx.jface.viewers.CellEditor;
import dwtx.jface.viewers.ColumnViewerEditor;
import dwtx.jface.viewers.ColumnViewer;
import dwtx.jface.viewers.ColumnViewerEditorActivationStrategy;
import dwtx.jface.viewers.ColumnViewerEditorActivationEvent;
import dwtx.jface.viewers.FocusCellOwnerDrawHighlighter;
import dwtx.jface.viewers.ICellModifier;
import dwtx.jface.viewers.ITreeContentProvider;
import dwtx.jface.viewers.TextCellEditor;
import dwtx.jface.viewers.TreePath;
import dwtx.jface.viewers.TreeViewerFocusCellManager;
import dwtx.jface.viewers.TreeViewerEditor;
import dwtx.jface.viewers.TreeViewer;
import dwtx.jface.viewers.Viewer;
import dwt.DWT;
import dwt.events.SelectionEvent;
import dwt.events.SelectionListener;
import dwt.layout.FillLayout;
import dwt.widgets.Button;
import dwt.widgets.Display;
import dwt.widgets.Item;
import dwt.widgets.Shell;

import dwt.dwthelper.utils;

import tango.util.Convert;
import tango.util.container.LinkedList;

version(JIVE) import jive.stacktrace;


void main(String[] args) {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new FillLayout());
    new Snippet043NoColumnTreeViewerKeyboardEditing(shell);
    shell.open();

    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }

    display.dispose();
}

/**
 * Demonstrates how to use keyboard-editing support in a TreeViewer with no column
 *
 * @author Tom Schindl <tom.schindl@bestsolution.at>
 *
 */
public class Snippet043NoColumnTreeViewerKeyboardEditing {
    alias LinkedList!(MyModel) ArrayList;
    public this(Shell shell) {
        Button b = new Button(shell, DWT.PUSH);
        b.setText("BBB");
        final TreeViewer v = new TreeViewer(shell, DWT.BORDER
                | DWT.FULL_SELECTION);
        b.addSelectionListener(new class(v) SelectionListener {
            TreeViewer v;
            this(TreeViewer v_)
            {
                this.v = v_;
            }

            public void widgetDefaultSelected(SelectionEvent e) {

            }

            public void widgetSelected(SelectionEvent e) {
                MyModel root = cast(MyModel) v.getInput();
                TreePath path = new TreePath([ root, root.child.get(1),
                        (cast(MyModel) root.child.get(1)).child.get(0)] );
                v.editElement(path, 0);
            }

        });

        v.setCellEditors([ new TextCellEditor(v.getTree()) ]);
        v.setColumnProperties(["col1"]);
        v.setCellModifier(new class(v) ICellModifier {
            TreeViewer v;
            this(TreeViewer v_)
            {
                this.v = v_;
            }
            public bool canModify(Object element, String property) {
                return true;
            }

            public Object getValue(Object element, String property) {
                return stringcast( to!(String)((cast(MyModel) element).counter) ~ "" );
            }

            public void modify(Object element, String property, Object value) {
                element = (cast(Item) element).getData();
                (cast(MyModel) element).counter = Integer.parseInt(value.toString());
                v.update(element, null);
            }

        });

        TreeViewerFocusCellManager focusCellManager = new TreeViewerFocusCellManager(
                v, new FocusCellOwnerDrawHighlighter(v));
        ColumnViewerEditorActivationStrategy actSupport = new class(v) ColumnViewerEditorActivationStrategy {
            this(ColumnViewer v)
            {
                super(v);
            }
            protected bool isEditorActivationEvent(
                    ColumnViewerEditorActivationEvent event) {
                return event.eventType == ColumnViewerEditorActivationEvent.TRAVERSAL
                        || event.eventType == ColumnViewerEditorActivationEvent.MOUSE_DOUBLE_CLICK_SELECTION
                        || (event.eventType == ColumnViewerEditorActivationEvent.KEY_PRESSED && event.keyCode == DWT.CR)
                        || event.eventType == ColumnViewerEditorActivationEvent.PROGRAMMATIC;
            }
        };

        TreeViewerEditor.create(v, focusCellManager, actSupport,
                ColumnViewerEditor.TABBING_HORIZONTAL
                        | ColumnViewerEditor.TABBING_MOVE_TO_ROW_NEIGHBOR
                        | ColumnViewerEditor.TABBING_VERTICAL
                        | ColumnViewerEditor.KEYBOARD_ACTIVATION);

        v.setContentProvider(new MyContentProvider());

        v.setInput(createModel());
    }

    private MyModel createModel() {

        MyModel root = new MyModel(0, null);
        root.counter = 0;

        MyModel tmp;
        MyModel subItem;
        for (int i = 1; i < 10; i++) {
            tmp = new MyModel(i, root);
            root.child.add(tmp);
            for (int j = 1; j < i; j++) {
                subItem = new MyModel(j, tmp);
                subItem.child.add(new MyModel(j * 100, subItem));
                tmp.child.add(subItem);
            }
        }

        return root;
    }



    private class MyContentProvider : ITreeContentProvider {

        public Object[] getElements(Object inputElement) {
            return (cast(MyModel) inputElement).child.toArray();
        }

        public void dispose() {
        }

        public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
        }

        public Object[] getChildren(Object parentElement) {
            return getElements(parentElement);
        }

        public Object getParent(Object element) {
            if (element is null) {
                return null;
            }
            return (cast(MyModel) element).parent;
        }

        public bool hasChildren(Object element) {
            return (cast(MyModel) element).child.size() > 0;
        }

    }

    public class MyModel {
        public MyModel parent;

        public ArrayList child;

        public int counter;

        public this(int counter_, MyModel parent_) {
            this.parent = parent_;
            this.counter = counter_;
            child = new ArrayList();
        }

        public String toString() {
            String rv = "Item ";
            if (parent !is null) {
                rv = parent.toString() ~ ".";
            }

            rv ~= to!(String)(counter);

            return rv;
        }
    }

}