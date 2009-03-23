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

module org.eclipse.jface.snippets.viewers.Snippet026TreeViewerTabEditing;


import org.eclipse.jface.viewers.CellEditor;
import org.eclipse.jface.viewers.ColumnLabelProvider;
import org.eclipse.jface.viewers.ColumnViewerEditor;
import org.eclipse.jface.viewers.ColumnViewer;
import org.eclipse.jface.viewers.ColumnViewerEditorActivationStrategy;
import org.eclipse.jface.viewers.EditingSupport;
import org.eclipse.jface.viewers.ColumnViewerEditorActivationEvent;
import org.eclipse.jface.viewers.FocusCellOwnerDrawHighlighter;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.TextCellEditor;
import org.eclipse.jface.viewers.TreePath;
import org.eclipse.jface.viewers.TreeViewerFocusCellManager;
import org.eclipse.jface.viewers.TreeViewerEditor;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.TreeViewerColumn;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;
import java.util.ArrayList;

import tango.util.Convert;

version(JIVE) import jive.stacktrace;


void main(String[] args) {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new FillLayout());
    new Snippet026TreeViewerTabEditing(shell);
    shell.open();

    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }

    display.dispose();
}

/**
 * A simple TreeViewer to demonstrate usage
 *
 * @author Tom Schindl <tom.schindl@bestsolution.at>
 *
 */
public class Snippet026TreeViewerTabEditing {
    public this(Shell shell) {
        Button b = new Button(shell,SWT.PUSH);
        b.setText("Remove column");
        final TreeViewer v = new TreeViewer(shell, SWT.BORDER
                | SWT.FULL_SELECTION);
        v.getTree().setLinesVisible(true);
        v.getTree().setHeaderVisible(true);
        b.addSelectionListener(new class(v) SelectionListener {
            TreeViewer v;
            this(TreeViewer v_)
            {
                this.v = v_;
            }
            public void widgetDefaultSelected(SelectionEvent e) {

            }

            public void widgetSelected(SelectionEvent e) {
                v.getTree().getColumn(1).dispose();
            }

        });

        TreeViewerFocusCellManager focusCellManager = new TreeViewerFocusCellManager(v,new FocusCellOwnerDrawHighlighter(v));
        ColumnViewerEditorActivationStrategy actSupport = new class(v) ColumnViewerEditorActivationStrategy {
            this(ColumnViewer v_)
            {
                super(v_);
            }
            protected bool isEditorActivationEvent(
                    ColumnViewerEditorActivationEvent event) {
                return event.eventType == ColumnViewerEditorActivationEvent.TRAVERSAL
                        || event.eventType == ColumnViewerEditorActivationEvent.MOUSE_DOUBLE_CLICK_SELECTION
                        || (event.eventType == ColumnViewerEditorActivationEvent.KEY_PRESSED && event.keyCode == SWT.CR)
                        || event.eventType == ColumnViewerEditorActivationEvent.PROGRAMMATIC;
            }
        };

        TreeViewerEditor.create(v, focusCellManager, actSupport, ColumnViewerEditor.TABBING_HORIZONTAL
                | ColumnViewerEditor.TABBING_MOVE_TO_ROW_NEIGHBOR
                | ColumnViewerEditor.TABBING_VERTICAL | ColumnViewerEditor.KEYBOARD_ACTIVATION);

        final TextCellEditor textCellEditor = new TextCellEditor(v.getTree());

        TreeViewerColumn column = new TreeViewerColumn(v, SWT.NONE);
        column.getColumn().setWidth(200);
        column.getColumn().setMoveable(true);
        column.getColumn().setText("Column 1");
        column.setLabelProvider(new class() ColumnLabelProvider {

            public String getText(Object element) {
                return "Column 1 => " ~ element.toString();
            }

        });
        column.setEditingSupport(new class(v) EditingSupport {
            this(ColumnViewer v_)
            {
                super(v_);
            }
            protected bool canEdit(Object element) {
                return false;
            }

            protected CellEditor getCellEditor(Object element) {
                return textCellEditor;
            }

            protected Object getValue(Object element) {
                return stringcast( (to!(String)((cast(MyModel) element).counter)) );
            }

            protected void setValue(Object element, Object value) {
                (cast(MyModel) element).counter = Integer.parseInt(value.toString());
                v.update(element, null);
            }
        });

        column = new TreeViewerColumn(v, SWT.NONE);
        column.getColumn().setWidth(200);
        column.getColumn().setMoveable(true);
        column.getColumn().setText("Column 2");
        column.setLabelProvider(new class() ColumnLabelProvider {

            public String getText(Object element) {
                return "Column 2 => " ~ element.toString();
            }

        });
        column.setEditingSupport(new class(v) EditingSupport {
            this(ColumnViewer v_)
            {
                super(v_);
            }
            protected bool canEdit(Object element) {
                return true;
            }

            protected CellEditor getCellEditor(Object element) {
                return textCellEditor;
            }

            protected Object getValue(Object element) {
                return stringcast( to!(String)((cast(MyModel) element).counter) );
            }

            protected void setValue(Object element, Object value) {
                (cast(MyModel) element).counter = Integer.parseInt(value.toString());
                v.update(element, null);
            }
        });

        column = new TreeViewerColumn(v, SWT.NONE);
        column.getColumn().setWidth(200);
        column.getColumn().setMoveable(true);
        column.getColumn().setText("Column 3");
        column.setLabelProvider(new class() ColumnLabelProvider {
            public String getText(Object element) {
                return "Column 3 => " ~ element.toString();
            }

        });
        column.setEditingSupport(new class(v) EditingSupport {
            this(ColumnViewer v_)
            {
                super(v_);
            }
            protected bool canEdit(Object element) {
                return true;
            }

            protected CellEditor getCellEditor(Object element) {
                return textCellEditor;
            }

            protected Object getValue(Object element) {
                return stringcast( to!(String)((cast(MyModel) element).counter) );
            }

            protected void setValue(Object element, Object value) {
                (cast(MyModel) element).counter = Integer.parseInt(value.toString());
                v.update(element, null);
            }
        });

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

        public this(int counter, MyModel parent) {
            this.parent = parent;
            this.counter = counter;
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
