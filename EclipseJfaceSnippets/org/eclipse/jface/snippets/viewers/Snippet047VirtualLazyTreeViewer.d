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

module org.eclipse.jface.snippets.viewers.Snippet047VirtualLazyTreeViewer;

import org.eclipse.jface.viewers.ILazyTreeContentProvider;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;

import tango.util.Convert;
import tango.util.container.LinkedList;

version(JIVE) import jive.stacktrace;


/**
 * @param args
 */
void main(String[] args) {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new FillLayout());
    new Snippet047VirtualLazyTreeViewer(shell);
    shell.open();

    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }

    display.dispose();

}

/**
 * A simple TreeViewer to demonstrate usage of an ILazyContentProvider.
 *
 */
public class Snippet047VirtualLazyTreeViewer {
    alias ArrayWrapperT!(IntermediateNode)  ArrayWrapperIntermediateNode;
    alias ArrayWrapperT!(LeafNode)  ArrayWrapperLeafNode;

    private class MyContentProvider : ILazyTreeContentProvider {
        private TreeViewer viewer;
        private IntermediateNode[] elements;

        public this(TreeViewer viewer) {
            this.viewer = viewer;
        }

        public void dispose() {

        }

        public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
            if(cast(ArrayWrapperIntermediateNode) newInput)
                this.elements = (cast(ArrayWrapperIntermediateNode) newInput).array;
        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.ILazyTreeContentProvider#getParent(java.lang.Object)
         */
        public Object getParent(Object element) {
            if (cast(LeafNode)element)
                return (cast(LeafNode) element).parent;
            return new ArrayWrapperIntermediateNode(elements);
        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.ILazyTreeContentProvider#updateChildCount(java.lang.Object,
         *      int)
         */
        public void updateChildCount(Object element, int currentChildCount) {

            int length = 0;
            if (cast(IntermediateNode)element) {
                IntermediateNode node = cast(IntermediateNode) element;
                length =  node.children.length;
            }
            /// TODO: fix me  access violation here
            if(element !is null && elements !is null && (cast(ArrayWrapperIntermediateNode)element) && (cast(ArrayWrapperIntermediateNode)element).array is elements)
                length = elements.length;
            viewer.setChildCount(element, length);
        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.ILazyTreeContentProvider#updateElement(java.lang.Object,
         *      int)
         */
        public void updateElement(Object parent, int index) {

            Object element;
            if (cast(IntermediateNode)parent)
                element = (cast(IntermediateNode) parent).children[index];

            else
                element =  elements[index];
            viewer.replace(parent, index, element);
            updateChildCount(element, -1);

        }

    }

    public class LeafNode {
        public int counter;
        public IntermediateNode parent;

        public this(int counter, IntermediateNode parent) {
            this.counter = counter;
            this.parent = parent;
        }

        public String toString() {
            return "Leaf " ~ to!(String)(this.counter);
        }
    }

    public class IntermediateNode {
        public int counter;
        public LeafNode[] children;

        public this(int counter) {
            this.counter = counter;
            children = new LeafNode[0];
        }

        public String toString() {
            return "Node " ~ to!(String)(this.counter);
        }

        public void generateChildren(int i) {
            children = new LeafNode[i];
            for (int j = 0; j < i; j++) {
                children[j] = new LeafNode(j, this);
            }

        }
    }

    public this(Shell shell) {
        final TreeViewer v = new TreeViewer(shell, SWT.VIRTUAL | SWT.BORDER);
        v.setLabelProvider(new LabelProvider());
        v.setContentProvider(new MyContentProvider(v));
        v.setUseHashlookup(true);
        IntermediateNode[] model = createModel();
        v.setInput(new ArrayWrapperIntermediateNode(model));
        v.getTree().setItemCount(model.length);

    }

    private IntermediateNode[] createModel() {
        IntermediateNode[] elements = new IntermediateNode[10];

        for (int i = 0; i < 10; i++) {
            elements[i] = new IntermediateNode(i);
            elements[i].generateChildren(1000);
        }

        return elements;
    }

}
