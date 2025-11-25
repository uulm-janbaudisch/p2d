mod parser;

pub use parser::parse;
use std::fmt::{Display, Formatter};

use bimap::{BiHashMap, BiMap};

pub struct OPBFile {
    pub name_map: BiMap<String, u32>,
    pub equations: Vec<Equation>,
    pub max_name_index: u32,
    pub number_constraints: usize,
    pub number_variables: usize,
}

impl OPBFile {
    pub fn new() -> OPBFile {
        OPBFile {
            name_map: BiHashMap::new(),
            equations: Vec::new(),
            max_name_index: 0,
            number_constraints: 0,
            number_variables: 0,
        }
    }
}

impl Display for OPBFile {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        writeln!(
            f,
            "* #variable= {} #constraint= {}",
            self.number_variables, self.number_constraints
        )?;
        self.equations
            .iter()
            .map(|equation| equation.to_string(&self.name_map))
            .try_for_each(|equation| writeln!(f, "{equation}"))
    }
}

#[derive(Clone)]
pub struct Equation {
    pub lhs: Vec<Summand>,
    pub rhs: i128,
    pub kind: EquationKind,
}

impl Equation {
    pub fn to_string(&self, variable_map: &BiMap<String, u32>) -> String {
        let lhs = self.lhs.iter().fold(String::new(), |mut output, summand| {
            output.push_str(summand.to_string(variable_map).as_str());
            output.push(' ');
            output
        });

        format!("{}{} {};", lhs, self.kind, self.rhs)
    }
}

#[derive(PartialEq, Debug, Clone)]
pub enum EquationKind {
    Eq,
    Ge,
    Le,
    G,
    L,
    NotEq,
}

impl Display for EquationKind {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        match self {
            EquationKind::Eq => write!(f, "="),
            EquationKind::Ge => write!(f, ">="),
            EquationKind::Le => write!(f, "<="),
            EquationKind::G => write!(f, ">"),
            EquationKind::L => write!(f, "<"),
            EquationKind::NotEq => write!(f, "!="),
        }
    }
}

#[derive(Clone)]
pub struct Summand {
    pub variable_index: u32,
    pub factor: i128,
    pub positive: bool,
}

impl Summand {
    pub fn to_string(&self, variable_map: &BiMap<String, u32>) -> String {
        let mut output = format!("{} ", self.factor);

        if !self.positive {
            output.push('-')
        }

        output.push_str(
            variable_map
                .get_by_right(&self.variable_index)
                .expect("variable not found"),
        );

        output
    }
}

#[cfg(test)]
mod test {
    use crate::parse;

    #[test]
    fn parse_and_display() {
        let input = r#"#variable= 7 #constraint= 2
x + 2 a + b + c >= 3;
-1 d + e + 1 * f >= 1;"#;

        let expected = r#"* #variable= 7 #constraint= 2
1 x 2 a 1 b 1 c >= 3;
-1 d 1 e 1 f >= 1;
"#;

        let parsed = parse(input).expect("failed to parse input");
        assert_eq!(parsed.to_string(), expected);
    }
}
