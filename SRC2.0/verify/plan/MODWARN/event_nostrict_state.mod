// codependent state events can't be strictly sequenced

math trajectory { 
  realDomain t; t.min=0; t.max=30; t.delta=0.01;
  realState A(t), B(t);
  when(t=t.min) { A=0; B=0; }
  event(B=0) A=0;
  event(A=0) B=0;
}
