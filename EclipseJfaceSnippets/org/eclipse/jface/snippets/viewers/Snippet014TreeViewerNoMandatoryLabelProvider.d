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

module org.eclipse.jface.snippets.viewers.Snippet014TreeViewerNoMandatoryLabelProvider;


import org.eclipse.jface.resource.FontRegistry;
import org.eclipse.jface.viewers.ITableColorProvider;
import org.eclipse.jface.viewers.ITableFontProvider;
import org.eclipse.jface.viewers.ITableLabelProvider;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.TreeColumn;

import java.lang.all;

import tango.util.Convert;
import tango.util.container.LinkedList;

version(JIVE) import jive.stacktrace;


void main(String[] args) {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new FillLayout());
    new Snippet014TreeViewerNoMandatoryLabelProvider(shell);
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
public class Snippet014TreeViewerNoMandatoryLabelProvider {
    alias  LinkedList!(MyModel) ArrayList;

    private class MyContentProvider : ITreeContentProvider {

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.IStructuredContentProvider#getElements(java.lang.Object)
         */
        public Object[] getElements(Object inputElement) {
            return (cast(MyModel) inputElement).child.toArray();
        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.IContentProvider#dispose()
         */
        public void dispose() {

        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.IContentProvider#inputChanged(org.eclipse.jface.viewers.Viewer,
         *      java.lang.Object, java.lang.Object)
         */
        public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {

        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.ITreeContentProvider#getChildren(java.lang.Object)
         */
        public Object[] getChildren(Object parentElement) {
            return getElements(parentElement);
        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.ITreeContentProvider#getParent(java.lang.Object)
         */
        public Object getParent(Object element) {
            if (element is null) {
                return null;
            }

            return (cast(MyModel) element).parent;
        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.ITreeContentProvider#hasChildren(java.lang.Object)
         */
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

    public class MyLabelProvider : LabelProvider,
            ITableLabelProvider, ITableFontProvider, ITableColorProvider {
        FontRegistry registry;
        this()
        {
            registry = new FontRegistry();
        }

        public Image getColumnImage(Object element, int columnIndex) {
            return null;
        }

        public String getColumnText(Object element, int columnIndex) {
            return "Column " ~ to!(String)(columnIndex) ~ " => " ~ element.toString();
        }

        public Font getFont(Object element, int columnIndex) {
            if ((cast(MyModel) element).counter % 2 == 0) {
                return registry.getBold(Display.getCurrent().getSystemFont()
                        .getFontData()[0].getName());
            }
            return null;
        }

        public Color getBackground(Object element, int columnIndex) {
            if ((cast(MyModel) element).counter % 2 == 0) {
                return Display.getCurrent().getSystemColor(SWT.COLOR_RED);
            }
            return null;
        }

        public Color getForeground(Object element, int columnIndex) {
            if ((cast(MyModel) element).counter % 2 == 1) {
                return Display.getCurrent().getSystemColor(SWT.COLOR_RED);
            }
            return null;
        }

    }

    public this(Shell shell) {
        final TreeViewer v = new TreeViewer(shell);

        TreeColumn column = new TreeColumn(v.getTree(),SWT.NONE);
        column.setWidth(200);
        column.setText("Column 1");

        column = new TreeColumn(v.getTree(),SWT.NONE);
        column.setWidth(200);
        column.setText("Column 2");

        v.setLabelProvider(new MyLabelProvider());
        v.setContentProvider(new MyContentProvider());
        v.setInput(createModel());
    }

    private MyModel createModel() {

        MyModel root = new MyModel(0, null);
        root.counter = 0;

        MyModel tmp;
        for (int i = 1; i < 10; i++) {
            tmp = new MyModel(i, root);
            root.child.add(tmp);
            for (int j = 1; j < i; j++) {
                tmp.child.add(new MyModel(j, tmp));
            }
        }

        return root;
    }


}
